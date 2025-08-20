//
//  NetworkSession.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/18/25.
//

import Foundation

/// Network сессия
public final class NetworkSession {
    public let session: URLSession

    // MARK: - Init
    public init(configuration: URLSessionConfiguration = .default) {
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.urlCache = configuration.urlCache ?? URLCache.shared
        self.session = URLSession(configuration: configuration)
    }

    @discardableResult
    public func data(for request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        return (data, http)
    }
}
