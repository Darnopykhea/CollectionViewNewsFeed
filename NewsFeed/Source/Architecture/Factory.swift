//
//  Architecture.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/15/25.
//

import Foundation
import UIKit

/// Описание общей фабрики
/// Для демо приложения Input не нужен,
/// но при расширении приложения понадобится
public protocol FactoryType: MakingViewControllerType {
    associatedtype Input
    associatedtype Dependencies

    init(input: Input, dependencies: Dependencies)
}

/// Описание фабрики вьюконтроллера
public protocol MakingViewControllerType {
    func makeObject() -> UIViewController
}
