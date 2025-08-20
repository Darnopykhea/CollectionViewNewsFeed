//
//  NewsItem.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/18/25.
//

import Foundation

/// Константы для запроса получения ленты
public enum NewsResponseConstants {
    static let path = "api/news"
}

/// Структура ответа на запрос получения ленты
public struct NewsResponse: Decodable {
    let news: [NewsItem]
    let total: Int?
    let hasMore: Bool?
}

/// Структура одной новости ленты
public struct NewsItem: Decodable {
    let id: Int
    let title: String
    let description: String
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String?
    let publishedDate: Date?
}
