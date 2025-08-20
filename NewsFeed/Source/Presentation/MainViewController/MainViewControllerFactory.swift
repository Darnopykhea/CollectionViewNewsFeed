//
//  MainViewControllerFactory.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/15/25.
//

import Foundation
import UIKit

/// Фабрика главного экрана
public struct MainViewControllerFactory: FactoryType {
    
    private let dependencies: MainDependencies
    
    public init(
        input: Void = (),
        dependencies: MainDependencies
    ) {
        self.dependencies = dependencies
    }
    
    public func makeObject() -> UIViewController {
        let vm = MainViewModel(dependencies: dependencies.viewModelDependencies)
        let vc = MainViewController(dependencies: dependencies.viewDependencies)
        vc.router = MainViewRouter()
        vc.viewModel = vm
        return vc
    }
    
    public static func makeDependencies() -> MainDependencies {
        MainDependencies(
            viewModelDependencies: makeViewModelDependencies(),
            viewDependencies: makeViewDependencies()
        )
    }
    
    private static func makeViewDependencies() -> MainViewDependencies {
        .init(imageLoader: ImageLoader())
    }
    
    private static func makeViewModelDependencies() -> MainViewModelDependencies {
        .init(apiClient: APIClient(baseURL: URL(string: Constants.API.baseURL)))
    }
}
