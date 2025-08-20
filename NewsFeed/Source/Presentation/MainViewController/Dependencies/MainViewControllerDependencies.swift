//
//  MainViewControllerDependencies.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/16/25.
//

import Foundation

/// Зависимости главного экрана
public struct MainDependencies {
    let viewModelDependencies: MainViewModelDependencies
    let viewDependencies: MainViewDependencies
}

/// Зависимости главного экрана(вью модель)
public struct MainViewModelDependencies {
    let apiClient: APIClientType
}

/// Зависимости главного экрана(вью)
public struct MainViewDependencies {
    let imageLoader: ImageLoaderType
}
