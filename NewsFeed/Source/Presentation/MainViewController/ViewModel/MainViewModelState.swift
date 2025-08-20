//
//  MainViewModelState.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/19/25.
//

import Foundation

/// Состояние главного экрана
final class MainViewModelState {
    var currentPage = MainViewModel.Constants.initialPage
    let pageSize = MainViewModel.Constants.pageSize

    var items: [NewsFeedCellViewModel] = []

    var hasMore: Bool = true
    var isLoading: Bool = false
}

