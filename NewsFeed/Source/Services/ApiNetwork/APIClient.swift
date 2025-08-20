//
//  ApiClient.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/18/25.
//

import Foundation

/// Апи клиент
public final class APIClient: APIClientType {
    private let baseURL: URL?
    private let session: NetworkSession

    // MARK: - Init
    public init(
        baseURL: URL?,
        session: NetworkSession = .init()
    ) {
        self.baseURL = baseURL
        self.session = session
    }

    public func getJSON<Response: Decodable>(
        path: String,
        pathParameters: [String]? = nil,
        decoder: JSONDecoder
    ) async throws -> Response {
        guard let baseURL = baseURL else {
            throw APICLientError.badURL(baseURL?.absoluteString ?? "")
        }
        
        var url = baseURL.appendingPathComponent(path)
        if let params = pathParameters {
            for param in params {
                url.appendPathComponent(param)
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, http) = try await session.data(for: request)
        guard (200..<300).contains(http.statusCode) else {
            throw APICLientError.status(http.statusCode)
        }

        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APICLientError.decoding(error)
        }
    }
}
