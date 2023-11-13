//
//  SiteDetailViewController.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/10/23.
//

import UIKit
import Combine

@available(iOS 17.0, *)
#Preview {
    let view = SiteDetailViewController(
        viewModel: SiteDetailViewModelImpl(
            site: .stubSamples[0]
        )
    )
    return view
}

enum SiteDetailAction {
    case onAppear
}

protocol SiteDetailViewModel {
    var items: AnyPublisher<[DevicePanelViewModel], Never> { get }
    func send(_ action: SiteDetailAction)

}

class SiteDetailViewController: UICollectionViewController {
    typealias ViewModel = SiteDetailViewModel
    typealias CellModel = DevicePanelViewModel
    
    private enum SiteDetailSection: Int {
        case main
    }
    
    private var viewModel: ViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SiteDetailSection, CellModel>!
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: .init())
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Setup Collection View
        collectionView.collectionViewLayout = makeCollectionViewLayout()
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource
        collectionView.backgroundColor = .secondarySystemBackground

        viewModel.items
            .sink { [weak self] items in
                self?.updateCollectionView(with: items)
            }
            .store(in: &cancellables)
        
        viewModel.send(.onAppear)
    }

    // MARK: -
    private func makeCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(200)
        )
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)
        ))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 30, leading: 15, bottom: 30, trailing: 15)
        return UICollectionViewCompositionalLayout(
            section: NSCollectionLayoutSection(group: group)
        )
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<SiteDetailSection, CellModel>! {
        let itemCellRegistration = UICollectionView.CellRegistration<DevicePanelCell, CellModel> { cell, indexPath, item in
            cell.viewModel = item
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) {
            collectionView, indexPath, item -> UICollectionViewCell in
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: item)
            return cell
        }
    }
    
    private func updateCollectionView(with items: [CellModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<SiteDetailSection, CellModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items)
        dataSource.apply(snapshot, animatingDifferences: true)
    }

}
