//
//  AreaDetailViewController.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/10/23.
//

import Foundation
import UIKit

extension Areas {
    struct AreaDetailViewModel {
        var items: [Device.PanelViewModel] = []
        
        static let empty: Self = .init()
    }
}

class AreaDetailViewController: UICollectionViewController {
    typealias ViewModel = Areas.AreaDetailViewModel
    typealias CellModel = Device.PanelViewModel
    
    private enum AreaDetailSection: Int {
        case main
    }
    
    var viewModel: ViewModel
    private var dataSource: UICollectionViewDiffableDataSource<AreaDetailSection, CellModel.ID>!
    
    private lazy var configuredCollectionViewLayout: UICollectionViewCompositionalLayout = {
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
    }()
    
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
        collectionView.collectionViewLayout = configuredCollectionViewLayout
        dataSource = makeDataSource()
        collectionView.dataSource = dataSource

        var snapshot = NSDiffableDataSourceSnapshot<AreaDetailSection, CellModel.ID>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.items.map { $0.id }, toSection: .main)
        dataSource.applySnapshotUsingReloadData(snapshot)
        
        collectionView.backgroundColor = .secondarySystemBackground
    }
    
    // MARK: - Delegate
    
    // MARK: -
    private func makeDataSource() -> UICollectionViewDiffableDataSource<AreaDetailSection, CellModel.ID>! {
        let itemCellRegistration = UICollectionView.CellRegistration<DevicePanelCell, CellModel> { cell, indexPath, item in
            cell.viewModel = item
        }
        
        return UICollectionViewDiffableDataSource(collectionView: collectionView) { [weak self]
            collectionView, indexPath, identifier -> UICollectionViewCell in
            guard let item = self?.viewModel.items.first(where: { $0.id == identifier }) else {
                return UICollectionViewCell()
            }
            let cell = collectionView.dequeueConfiguredReusableCell(using: itemCellRegistration, for: indexPath, item: item)

#if DEBUG
//            cell.contentView.backgroundColor = .green
#endif
            return cell
        }
    }
}

@available(iOS 17.0, *)
#Preview {
    let view = AreaDetailViewController(viewModel: .init(
        items: [
            .init(
                id: 0,
                vital: Device.StatusViewModel(
                    coverImage: .sensorFill,
                    title: "Sensor",
                    // status: [...],
                    caption: "Updated 12:31 AM",
                    isStatusIconsBarVisible: true
                ),
                measurements: [
                    Device.StatusViewModel(
                        coverImage: .thermometer,
                        title: "22.3 " + .celcius,
                        // status: [...],
                        caption: "Warm",
                        isStatusIconsBarVisible: false
                    ),
                    Device.StatusViewModel(
                        coverImage: .humidity,
                        title: "65%",
                        // status: [...],
                        caption: "Above average",
                        isStatusIconsBarVisible: false
                    ),
                    Device.StatusViewModel(
                        coverImage: .noiseSensor,
                        title: "37 dB",
                        // status: [...],
                        caption: "Calm",
                        isStatusIconsBarVisible: false
                    ),
                ]
            )
        ]))
    return view
}
