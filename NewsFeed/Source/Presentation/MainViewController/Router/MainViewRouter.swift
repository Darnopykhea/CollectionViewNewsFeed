//
//  MainViewRouter.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import UIKit
import SafariServices

/// Роутер главного экрана
final class MainViewRouter: MainViewRouterType {
    func showDetails(from presenter: UIViewController, url: URL) {
        let safari = SFSafariViewController(url: url)
        presenter.present(safari, animated: true)
    }
}
