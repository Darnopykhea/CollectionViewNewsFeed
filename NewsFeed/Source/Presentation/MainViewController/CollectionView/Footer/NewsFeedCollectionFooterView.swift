//
//  NewsFeedCollectionFooterView.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import Foundation
import UIKit

/// Футер для коллекции главного экрана
final class NewsFeedCollectionFooterView: UICollectionReusableView {
    static let kind = UICollectionView.elementKindSectionFooter
    static let reuseId = Constants.reuseId
    private let spinner = UIActivityIndicatorView(style: .medium)

    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setLoading(_ loading: Bool) {
        loading ? spinner.startAnimating() : spinner.stopAnimating()
    }
}

private extension NewsFeedCollectionFooterView {
    enum Constants {
        static let reuseId = "LoadingFooterView"
    }
}
