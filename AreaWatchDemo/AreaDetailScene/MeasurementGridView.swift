//
//  MeasurementGridView.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/10/23.
//

import Foundation
import UIKit

@available(iOS 17.0, *)
#Preview {
    let view = MeasurementsGridView()
    view.items = [
        Device.StatusViewModel(
            coverImage: .thermometer?.withTintColor(.gray, renderingMode: .alwaysOriginal),
            title: "22.3 " + .celcius,
            // status: [...],
            caption: "Warm",
            isStatusIconsBarVisible: false
        ),
        Device.StatusViewModel(
            coverImage: .humidity?.withTintColor(.gray, renderingMode: .alwaysOriginal),
            title: "65%",
            // status: [...],
            caption: "Above average",
            isStatusIconsBarVisible: false
        ),
        Device.StatusViewModel(
            coverImage: .noiseSensor?.withTintColor(.gray, renderingMode: .alwaysOriginal),
            title: "37 dB",
            // status: [...],
            caption: "Calm",
            isStatusIconsBarVisible: false
        ),
    ]
    return view
}

// MARK: -
extension MeasurementsGridView {
    struct StyleConfig: GlobalStyleConfig {
    }
}

class MeasurementsGridView: UIView {
    typealias ViewModel = Device.StatusViewModel
    
    private let sc: StyleConfig = StyleConfig()
    private let maxMeasurements = 4
    private var numColumns: Int { maxMeasurements / 2 }

    var items: [ViewModel] = [] {
        didSet {
            zip(deviceStatusViews, items)
                .forEach { view, viewModel in
                view.viewModel = viewModel
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        items = (0..<maxMeasurements).map { _ in .empty }
        
        addSubview(verticalLayoutView)

        NSLayoutConstraint.activate([
            verticalLayoutView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: sc.borderMargin),
            verticalLayoutView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -sc.borderMargin),
            verticalLayoutView.topAnchor.constraint(equalTo: topAnchor, constant: sc.borderMargin),
            verticalLayoutView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -sc.borderMargin),
        ])

#if DEBUG
        // Set colors to views and debug layout: `captionBar.backgroundColor = .pink`
#endif
    }
        
// MARK: - Subviews
    private lazy var verticalLayoutView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = sc.layoutGap
        view.distribution = .fillEqually
        
        view.addArrangedSubview(firstRowLayoutView)
        view.addArrangedSubview(secondRowLayoutView)
        return view
    }()

    private lazy var firstRowLayoutView: UIView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = sc.layoutGap
        view.distribution = .fillEqually

        deviceStatusViews.prefix(numColumns).forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var secondRowLayoutView: UIView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.spacing = sc.layoutGap
        view.distribution = .fillEqually

        deviceStatusViews.suffix(numColumns).forEach {
            view.addArrangedSubview($0)
        }
        return view
    }()
    
    private lazy var deviceStatusViews: [UIDeviceStatusView] = {
        let numViews = 0..<maxMeasurements
        return numViews.map {_ in UIDeviceStatusView(.small) }
    }()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


