//
//  AppDelegate.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/15/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        let vc = makeInitialViewController()
        window.rootViewController = UINavigationController(rootViewController: vc)
        self.window = window
        window.makeKeyAndVisible()
        return true
    }
    
    private func makeInitialViewController() -> UIViewController {
        let dependencies = MainViewControllerFactory.makeDependencies()
        let factory = MainViewControllerFactory(dependencies: dependencies)
        return factory.makeObject()
    }
}

