//
//  NewsFeedCollectionViewLayout.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/18/25.
//

import Foundation
import UIKit

/// Лайаут для коллекции главного экрана
enum NewsFeedCollectionViewLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { _, env in
            let isRegular = env.traitCollection.horizontalSizeClass == .regular
            let columns = isRegular ? Constants.regularColumns : Constants.compactColumns
            let rowFraction = isRegular ? Constants.regularRowFraction : Constants.compactRowFraction

            let item = NSCollectionLayoutItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(Constants.fullFraction / CGFloat(columns)),
                    heightDimension: .fractionalHeight(Constants.fullFraction)
                )
            )
            item.contentInsets = .init(
                top: Constants.itemInsets,
                leading: Constants.itemInsets,
                bottom: Constants.itemInsets,
                trailing: Constants.itemInsets
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(Constants.fullFraction),
                    heightDimension: .fractionalHeight(rowFraction)
                ),
                repeatingSubitem: item,
                count: columns
            )

            let section = NSCollectionLayoutSection(group: group)
            section.interGroupSpacing = Constants.interGroupSpacing
            section.contentInsets = .init(
                top: Constants.sectionInsets,
                leading: Constants.sectionInsets,
                bottom: Constants.sectionInsets,
                trailing: Constants.sectionInsets
            )

            // футер (индикатор загрузки)
            let footer = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(Constants.fullFraction),
                    heightDimension: .absolute(Constants.footerHeight)
                ),
                elementKind: NewsFeedCollectionFooterView.kind,
                alignment: .bottom
            )
            section.boundarySupplementaryItems = [footer]

            return section
        }
    }
}

private extension NewsFeedCollectionViewLayout {
    enum Constants {
        // Базовые значения
        static let fullFraction: CGFloat = 1.0

        // Колонки
        static let compactColumns = 1
        static let regularColumns = 2

        // Пропорции высоты строки
        static let compactRowFraction: CGFloat = fullFraction / 5.5
        static let regularRowFraction: CGFloat = fullFraction / 7.0

        // Отступы
        static let itemInsets: CGFloat = 8
        static let sectionInsets: CGFloat = 12
        static let interGroupSpacing: CGFloat = 8

        // Футер
        static let footerHeight: CGFloat = 44
    }
}
