//
//  MainViewModel.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/16/25.
//

import Foundation
import Combine

/// Модель главного экрана
final class MainViewModel: MainViewModelType {

    private let apiClient: APIClientType
    private let state = MainViewModelState()
    
    private let itemsSubject     = CurrentValueSubject<[NewsFeedCellViewModel], Never>([])
    private let isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
    private let hasMoreSubject   = CurrentValueSubject<Bool, Never>(true)
    private let errorSubject     = CurrentValueSubject<String?, Never>(nil)
    
    var itemsPublisher: AnyPublisher<[NewsFeedCellViewModel], Never> { itemsSubject.eraseToAnyPublisher() }
    var isLoadingPublisher: AnyPublisher<Bool, Never> { isLoadingSubject.eraseToAnyPublisher() }
    var hasMorePublisher: AnyPublisher<Bool, Never> { hasMoreSubject.eraseToAnyPublisher() }
    var errorPublisher: AnyPublisher<String?, Never> { errorSubject.eraseToAnyPublisher() }

    // MARK: - Init
    init(dependencies: MainViewModelDependencies) {
        self.apiClient = dependencies.apiClient
    }

    func fetchNews(reset: Bool) async {
        if reset {
            state.currentPage = Constants.initialPage
            state.items = []
            state.hasMore = true
            itemsSubject.send(state.items)
            hasMoreSubject.send(state.hasMore)
            errorSubject.send(nil)
        } else {
            guard state.hasMore, state.isLoading == false else { return }
            state.currentPage += 1
        }
        
        state.isLoading = true
        isLoadingSubject.send(true)
        errorSubject.send(nil)
        
        do {
            let response: NewsResponse = try await apiClient.getJSON(
                path: NewsResponseConstants.path,
                pathParameters: [String(state.currentPage), String(state.pageSize)],
                decoder: .iso8601Friendly
            )
            
            let mapped = response.news.map { NewsFeedCellViewModel(item: $0) }
            
            if reset {
                state.items = mapped
            } else {
                state.items.append(contentsOf: mapped)
            }
            
            state.hasMore = response.hasMore ?? (mapped.count == state.pageSize)
            
            itemsSubject.send(state.items)
            hasMoreSubject.send(state.hasMore)
            errorSubject.send(nil)
        } catch {
            // откат страницы при ошибке догрузки
            if !reset {
                state.currentPage = max(Constants.initialPage, state.currentPage - 1)
            }
            errorSubject.send(error.localizedDescription)
        }
        
        state.isLoading = false
        isLoadingSubject.send(false)
    }

    func shouldLoadMore(visibleIndex: Int) -> Bool {
        guard state.hasMore, state.isLoading == false else { return false }
        let threshold = max(0, state.items.count - 5)
        return visibleIndex >= threshold
    }
}

extension MainViewModel {
    enum Constants {
        static let initialPage = 1
        static let pageSize = 15
    }
}

