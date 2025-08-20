//
//  AssertionFailureSafety.swift
//  NewsFeed
//
//  Created by Evgeniy Darnopykh on 8/20/25.
//

import UIKit
import Combine

/// Главный экран
final class MainViewController: UIViewController {

    private let imageLoader: ImageLoaderType
    var viewModel: MainViewModelType? {
        didSet { bind(to: viewModel) }
    }
    
    var router: MainViewRouterType?

    private var collectionView: UICollectionView?
    private var cellRegistration: UICollectionView.CellRegistration<NewsFeedCell, NewsFeedCellViewModel>?
    private var dataSource: UICollectionViewDiffableDataSource<NewsFeedSection, NewsFeedCellViewModel>?
    private weak var loadingFooter: NewsFeedCollectionFooterView?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(dependencies: MainViewDependencies) {
        self.imageLoader = dependencies.imageLoader
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureCollectionViewAndDataSource()
    }
    
    private func configureUI() {
        title = Constants.title
        view.backgroundColor = .systemBackground
    }
}

// MARK: - Binding
extension MainViewController {
    func bind(to viewModel: MainViewModelType?) {
        guard let viewModel else { return }

        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.applySnapshot(items)
            }
            .store(in: &cancellables)

        viewModel.isLoadingPublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                self?.loadingFooter?.setLoading(isLoading)
            }
            .store(in: &cancellables)

        viewModel.hasMorePublisher
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] hasMore in
                if !hasMore {
                    self?.loadingFooter?.isHidden = false
                } else {
                    self?.loadingFooter?.setLoading(false)
                    self?.loadingFooter?.isHidden = true
                }
            }
            .store(in: &cancellables)

        viewModel.errorPublisher
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.showErrorAlert(message)
            }
            .store(in: &cancellables)

        Task { await viewModel.fetchNews(reset: true) }
    }
}

// MARK: - CollectionView DataSource
private extension MainViewController {
    func configureCollectionViewAndDataSource() {
        configureCollectionView()
        registerCell()
        configureDiffableDataSource()
    }
    
    func configureCollectionView() {
        let collectionView = UICollectionView(
            frame: view.bounds,
            collectionViewLayout: NewsFeedCollectionViewLayout.make()
        )
        collectionView.delegate = self
        collectionView.prefetchDataSource = self

        collectionView.register(
            NewsFeedCollectionFooterView.self,
            forSupplementaryViewOfKind: NewsFeedCollectionFooterView.kind,
            withReuseIdentifier: NewsFeedCollectionFooterView.reuseId
        )

        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
    
    func registerCell() {
        cellRegistration = UICollectionView.CellRegistration<NewsFeedCell, NewsFeedCellViewModel> { [weak self] cell, _, viewModel in
            guard let self = self else { return }
            cell.viewModel = viewModel

            guard let url = viewModel.imageURL else {
                cell.setImage(nil, ifMatches: viewModel.id)
                return
            }

            Task { [weak cell] in
                if let cached = await self.imageLoader.cachedImage(for: url) {
                    await MainActor.run { cell?.setImage(cached, ifMatches: viewModel.id) }
                    return
                }

                do {
                    let image = try await self.imageLoader.load(url)
                    await MainActor.run { cell?.setImage(image, ifMatches: viewModel.id) }
                } catch {
                    // Можно здесь показать ошибку но если будет много неудачных загрузок
                    // для пользователя это будет хуже чем ячейка без картинки
                    await MainActor.run { cell?.setImage(nil, ifMatches: viewModel.id) }
                }
            }
        }
    }
    
    func configureDiffableDataSource() {
        guard let collectionView = collectionView,
              let cellRegistration = cellRegistration
        else {
            return
        }
            
        let diffableDataSource = UICollectionViewDiffableDataSource<NewsFeedSection, NewsFeedCellViewModel>(collectionView: collectionView) {
            collectionView, indexPath, item in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
        }

        diffableDataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            guard kind == NewsFeedCollectionFooterView.kind,
                  let footer = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: NewsFeedCollectionFooterView.reuseId,
                    for: indexPath
                  ) as? NewsFeedCollectionFooterView else {
                return nil
            }
            footer.setLoading(false)
            return footer
        }

        self.dataSource = diffableDataSource
    }

    func applySnapshot(_ items: [NewsFeedCellViewModel]) {
        guard let dataSource else { return }
        var snapshot = NSDiffableDataSourceSnapshot<NewsFeedSection, NewsFeedCellViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension MainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        guard elementKind == NewsFeedCollectionFooterView.kind,
              let footer = view as? NewsFeedCollectionFooterView else {
            return
        }
        
        loadingFooter = footer
    }
    
    // Пагинация
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        if viewModel.shouldLoadMore(visibleIndex: indexPath.item) {
            Task { await viewModel.fetchNews(reset: false) }
        }
    }

    // Отмена загрузки у уехавших (для перформанса)
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let vm = dataSource?.itemIdentifier(for: indexPath),
              let url = vm.imageURL else { return }
        Task { await imageLoader.cancel(url) }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource?.itemIdentifier(for: indexPath),
              let url = item.fullURL else { return }
        router?.showDetails(from: self, url: url)
    }
}

// MARK: - Prefetch
extension MainViewController: UICollectionViewDataSourcePrefetching {
    /// Для ячеек которые система предпологает что появятся на экране
    /// заранее пытаемся скачать и закэшировать
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        guard let snapshot = dataSource?.snapshot() else { return }

        for indexPath in indexPaths {
            guard indexPath.item < snapshot.numberOfItems else { continue }
            let item = snapshot.itemIdentifiers[indexPath.item]
            guard let url = item.imageURL else { continue }

            Task.detached(priority: .utility) { [imageLoader] in
                if let _ = await imageLoader.cachedImage(for: url) { return }
                _ = try? await imageLoader.load(url)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        guard let snapshot = dataSource?.snapshot() else { return }
        for indexPath in indexPaths {
            guard indexPath.item < snapshot.numberOfItems else { continue }
            let item = snapshot.itemIdentifiers[indexPath.item]
            guard let url = item.imageURL else { continue }
            Task { await imageLoader.cancel(url) }
        }
    }
}

// MARK: - Error handling
extension MainViewController {
    private func showErrorAlert(_ message: String) {
        let errorMessage = message.isEmpty ? Constants.readableError : message
        
        let alert = UIAlertController(
            title: Constants.title,
            message: errorMessage,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: Constants.errorActionTitle, style: .default))
        present(alert, animated: true)
    }
}

extension MainViewController {
    enum Constants {
        static let readableError = "К сожалению не получилось обработать запрос, попробуйте позже"
        static let title = "News"
        static let errorTitle = "Error"
        static let errorActionTitle = "OK"
    }
}
