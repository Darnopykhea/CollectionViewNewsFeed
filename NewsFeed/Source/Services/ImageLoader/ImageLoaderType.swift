//
//  ImageLoaderType.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import Foundation
import UIKit

/// Описание класса для кэширования изображений
public protocol ImageLoaderType: Actor {
    func cachedImage(for url: URL) -> UIImage?
    func load(_ url: URL) async throws -> UIImage
    func cancel(_ url: URL)
}
