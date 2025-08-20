//
//  MainViewModelType.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/16/25.
//

import Foundation
import Combine
import UIKit

/// Описание вью-модели главного экрана
protocol MainViewModelType {
    var itemsPublisher: AnyPublisher<[NewsFeedCellViewModel], Never> { get }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var hasMorePublisher: AnyPublisher<Bool, Never> { get }
    var errorPublisher: AnyPublisher<String?, Never> { get }

    func fetchNews(reset: Bool) async
    func shouldLoadMore(visibleIndex: Int) -> Bool
}
