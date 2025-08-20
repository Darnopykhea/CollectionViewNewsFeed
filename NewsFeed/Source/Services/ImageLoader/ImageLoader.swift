//
//  ImageLoader.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import UIKit
import Foundation
import CryptoKit

/// Сервис для загрузки, кэширования и хранения изображений
actor ImageLoader: ImageLoaderType {

    private let memoryCache = NSCache<NSURL, UIImage>()
    private var tasks: [URL: Task<UIImage, Error>] = [:]
    private let session: URLSession
    private let urlCache: URLCache

    // MARK: - Init
    init(
        memoryMB: Int = Constants.memorySizeMB,
        diskMB: Int = Constants.diskSizeMB
    ) {
        let memoryCapacity = memoryMB * 1024 * 1024
        let diskCapacity = diskMB * 1024 * 1024

        let cache = URLCache(
            memoryCapacity: memoryCapacity,
            diskCapacity: diskCapacity,
            diskPath: Constants.diskPath
        )
        self.urlCache = cache

        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        config.urlCache = cache
        self.session = URLSession(configuration: config)

        try? FileManager.default.createDirectory(
            at: Self.imagesCacheDirURL,
            withIntermediateDirectories: true
        )
    }
}

// MARK: - API (actor-isolated)
extension ImageLoader {
    func cachedImage(for url: URL) -> UIImage? {
        lookupCachedImage(for: url)
    }

    func load(_ url: URL) async throws -> UIImage {
        if let image = lookupCachedImage(for: url) {
            return image
        }
        
        if let running = tasks[url] {
            return try await running.value
        }
        
        let request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalCacheData,
            timeoutInterval: Constants.timeout
        )
        
        let imageLoadingTask = Task { () throws -> UIImage in
            let (data, response) = try await session.data(for: request)
            guard let img = UIImage(data: data) else {
                throw URLError(.cannotDecodeRawData)
            }
            
            let cached = CachedURLResponse(response: response, data: data)
            self.urlCache.storeCachedResponse(cached, for: request)
            self.memoryCache.setObject(img, forKey: url as NSURL)
            self.saveFileToStorage(data: data, for: url)
            
            self.tasks[url] = nil
            return img
        }
        
        tasks[url] = imageLoadingTask
        let result = try await imageLoadingTask.value
        tasks[url] = nil
        return result
    }

    func cancel(_ url: URL) {
        tasks[url]?.cancel()
        tasks[url] = nil
    }
    
    /// Попытка найти сохраненное изображение в кэше, файловой системе, в URLCache
    private func lookupCachedImage(for url: URL) -> UIImage? {
        // Попытка найти в NSCache
        if let image = memoryCache.object(forKey: url as NSURL) {
            return image
        }

        // Попытка найти в файловой системе
        if let image = loadFileFromStorage(url) {
            memoryCache.setObject(image, forKey: url as NSURL)
            return image
        }

        // Попытка найти в URLCache
        let request = URLRequest(
            url: url,
            cachePolicy: .returnCacheDataDontLoad,
            timeoutInterval: Constants.timeout
        )
        
        if let cached = urlCache.cachedResponse(for: request),
           let image = UIImage(data: cached.data) {
            memoryCache.setObject(image, forKey: url as NSURL)
            saveFileToStorage(data: cached.data, for: url)
            return image
        }

        return nil
    }
}

// MARK: - File system

/// При тестировании выяснилось что просто кэша недостаточно для избавления
/// от пустых ячеек при возвращении приложения в активное состояние,
/// сохранение в файловую систему решает проблему
private extension ImageLoader {
    
    /// Директория файловой системы с загруженными изображениями
    private static var imagesCacheDirURL: URL = {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return base.appendingPathComponent("Images", isDirectory: true)
    }()

    /// Полный путь к файлу в файловой системе
    private func filePath(for url: URL) -> URL {
        let key = Insecure.MD5.hash(data: Data(url.absoluteString.utf8))
            .map { String(format: "%02hhx", $0) }
            .joined()
        return Self.imagesCacheDirURL.appendingPathComponent(key).appendingPathExtension("img")
    }

    /// Загрузка файла из файловой системы
    private func loadFileFromStorage(_ url: URL) -> UIImage? {
        let path = filePath(for: url)
        guard let data = try? Data(contentsOf: path),
              let image = UIImage(data: data) else { return nil }
        return image
    }

    /// Сохранение файла в файловую систему
    private func saveFileToStorage(data: Data, for url: URL) {
        let path = filePath(for: url)
        try? data.write(to: path, options: .atomic)
    }
}

// MARK: - Constants
private extension ImageLoader {
    enum Constants {
        static let memorySizeMB = 64
        static let diskSizeMB = 64
        static let diskPath = "ImageURLCache"
        static let timeout: Double = 60
    }
}
