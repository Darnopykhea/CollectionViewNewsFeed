//
//  ApiClientType.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/19/25.
//

import Foundation

/// Описание Апи клиента
public protocol APIClientType {
    func getJSON<Response: Decodable>(
        path: String,
        pathParameters: [String]?,
        decoder: JSONDecoder
    ) async throws -> Response
}
