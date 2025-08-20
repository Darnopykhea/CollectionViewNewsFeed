//
//  APIClientError.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/19/25.
//

import Foundation

/// Описание ошибки Апи клиента
public enum APICLientError: Error {
    case status(Int)
    case decoding(Error)
    case badURL(String)
}
