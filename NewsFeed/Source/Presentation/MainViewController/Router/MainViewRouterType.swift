//
//  MainViewRouterType.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import Foundation
import UIKit

/// Описание роутера главного экрана
protocol MainViewRouterType: AnyObject {
    func showDetails(from presenter: UIViewController, url: URL)
}
