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
            site: .stubSamples[0],
            events: PassthroughSubject<SiteEvent, Never>().eraseToAnyPublisher(),
            logger: DemoAppLogger()
        )
    )
    return view
}

enum SiteDetailAction {
    case onAppear
}

protocol SiteDetailViewModel {
    var title: String { get }
    var items: AnyPublisher<[SiteDetailItemChange], Never> { get }
    func send(_ action: SiteDetailAction)

}

struct SiteDetailItemChange: Identifiable {
    enum Change {
        case unchanged
        case add
        case update
    }
    
    var id: Int { item.id }
    var change: Change
    var item: DevicePanelViewModel
}

class SiteDetailViewController: UICollectionViewController {
    typealias ViewModel = SiteDetailViewModel
    typealias CellModel = DevicePanelViewModel
    
    private enum SiteDetailSection: Int {
        case main
    }
    
    private var viewModel: ViewModel
    private var dataSource: UICollectionViewDiffableDataSource<SiteDetailSection, CellModel.ID>!
    private var cancellables: Set<AnyCancellable> = []
    private var items: [CellModel] = []
                                      
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

        title = viewModel.title
        viewModel.items
            .receive(on: RunLoop.main)
            .sink { [weak self] changes in
                self?.items = changes.map { $0.item}
                self?.updateCollectionView(
                    added: changes.filter { $0.change == .add }.map { $0.item.id },
                    updated: changes.filter { $0.change == .update }.map { $0.item.id }
                )
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

        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        group.contentInsets = .init(top: 30, leading: 15, bottom: 30, trailing: 15)
        return UICollectionViewCompositionalLayout(
            section: NSCollectionLayoutSection(group: group)
        )
    }
    
    private func makeDataSource() -> UICollectionViewDiffableDataSource<SiteDetailSection, CellModel.ID>! {
        let itemCellRegistration = UICollectionView.CellRegistration<DevicePanelCell, CellModel> { cell, indexPath, item in
            cell.viewModel = item
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self]
            collectionView, indexPath, itemIndex -> UICollectionViewCell in
            let item = self?.items[itemIndex]
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: item)
            return cell
        }
    }
    
    private func updateCollectionView(added: [CellModel.ID], updated: [CellModel.ID]) {

        if !added.isEmpty {
            var snapshot = NSDiffableDataSourceSnapshot<SiteDetailSection, CellModel.ID>()
            snapshot.appendSections([.main])
            snapshot.appendItems(added, toSection: .main)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        if !updated.isEmpty {
            var snapshot = dataSource.snapshot()
            snapshot.reconfigureItems(updated)
            dataSource.apply(snapshot, animatingDifferences: true)
        }
    }

}
