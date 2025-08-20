//
//  NewsFeedCellViewModel.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/19/25.
//

import Foundation

/// Модель для ячейки коллекции главного экрана
struct NewsFeedCellViewModel: Hashable, Identifiable {
    let id: String

    let title: String
    let imageURL: URL?
    let fullURL: URL?

    init(item: NewsItem) {
        self.id = UUID().uuidString
        self.title = item.title
        self.imageURL = item.titleImageUrl.flatMap(URL.init(string:))
        self.fullURL  = URL(string: item.fullUrl)
    }

    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}




