//
//  DevicePanelCell.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

/// Device Panel
/// |                |
/// | [Vital]    |  [Measure1]   [Measure2]
/// | [   ]    |  [Measure1]   [Measure2]
/// |                |
class DevicePanelCell: UICollectionViewCell {
    typealias ViewModel = Device.PanelViewModel
    var viewModel: ViewModel = .init(id: 0, vital: .empty, measurements: []) {
        didSet {
            vital.viewModel = viewModel.vital
            measurementsGrid.items = viewModel.measurements
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(layoutView)
        layoutView.pinEdges(to: contentView, border: sc.borderMargin)
        
        NSLayoutConstraint.activate([
            vital.widthAnchor.constraint(equalTo: measurementsGrid.widthAnchor, multiplier: 0.7),
            vital.heightAnchor.constraint(equalTo: layoutView.heightAnchor),
            measurementsGrid.heightAnchor.constraint(equalTo: layoutView.heightAnchor),
        ])

        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = sc.borderColor.cgColor

#if DEBUG
//        vital.backgroundColor = .systemGray
//        measurementsGrid.backgroundColor = .systemGray
//        contentView.backgroundColor = .green
#endif
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: -
    private let sc: StyleConfig = StyleConfig()

    private lazy var layoutView: UIView = {
        let view = HorizontalBar(
            subviews: [vital, measurementsGrid],
            separatorColor: sc.borderColor
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var vital: UIDeviceStatusView = {
        let view = UIDeviceStatusView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var measurementsGrid: MeasurementsGridView = {
        let view = MeasurementsGridView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
}

extension DevicePanelCell {
    struct StyleConfig: GlobalStyleConfig {
        let borderColor: UIColor = .systemGray3.withAlphaComponent(0.5)
    }
}

@available(iOS 17.0, *)
#Preview {
    let cell = DevicePanelCell()
    
    cell.viewModel = Device.PanelViewModel(
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
    
    cell.widthAnchor.constraint(equalToConstant: 400).isActive = true
    cell.heightAnchor.constraint(equalToConstant: 200).isActive = true
    return cell
}
