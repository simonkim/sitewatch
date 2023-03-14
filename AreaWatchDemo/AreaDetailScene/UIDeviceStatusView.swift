//
//  UIDeviceStatusView.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/10/23.
//

import Foundation
import UIKit

@available(iOS 17.0, *)
#Preview {
    let view = UIDeviceStatusView(.small)
    view.viewModel = Device.StatusViewModel(
        coverImage: .thermometer,
        title: "Sensor",
        // status: [...],
        caption: "Updated 12:31 AM",
        isStatusIconsBarVisible: true
    )

    view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    view.widthAnchor.constraint(equalToConstant: 100).isActive = true
    return view
}

// MARK: -

extension UIImage {
    static var sensorFill: UIImage? {
        UIImage(systemName: "sensor.fill")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
    static var thermometer: UIImage? {
        UIImage(systemName: "thermometer.medium")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
    static var humidity: UIImage? {
        UIImage(systemName: "drop.degreesign")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
    static var noiseSensor: UIImage? {
        UIImage(systemName: "ear.badge.waveform")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
    }
}

extension UIDeviceStatusView {
    struct StyleConfig: GlobalStyleConfig {

        let coverImageSizes: [UIDeviceStatusView.SizeClass: CGFloat] = [
            .small: 44, .regular: 88, .large: 132
        ]
        let captionHeights: [UIDeviceStatusView.SizeClass: CGFloat] = [
            .small: 12, .regular: 18, .large: 24
        ]
        
        func coverImageSize(for sizeClass: UIDeviceStatusView.SizeClass) -> CGFloat {
            return coverImageSizes[sizeClass] ?? coverImageSizes[.regular]!
        }
    }
}

class UIDeviceStatusView: UIView {
    typealias ViewModel = Device.StatusViewModel
    enum SizeClass {
        case small
        case regular
        case large
    }
    
    private let sc: StyleConfig = StyleConfig()
    
    var viewModel: ViewModel = .empty {
        didSet {
            titleLabel.text = viewModel.title
            coverImage.image = viewModel.coverImage
            statusIconsBar.isHidden = !viewModel.isStatusIconsBarVisible
            captionBar.text = viewModel.caption
        }
    }
    private let sizeClass: SizeClass
    init(_ sizeClass: SizeClass = .regular) {
        self.sizeClass = sizeClass
        super.init(frame: .zero)
        
        addSubview(verticalLayoutView)
        verticalLayoutView.addArrangedSubview(titledDevice)
        verticalLayoutView.addArrangedSubview(statusIconsBar)
        verticalLayoutView.addArrangedSubview(captionBar)
        verticalLayoutView.pinEdges(to: self, border: sc.borderMargin)

        NSLayoutConstraint.activate([
            statusIconsBar.heightAnchor.constraint(equalTo: captionBar.heightAnchor),
            captionBar.heightAnchor.constraint(equalToConstant: sc.captionHeights[sizeClass] ?? sc.captionHeights[.regular]!),
        ])

#if DEBUG
        // Set colors to views and debug layout: `captionBar.backgroundColor = .orange`
//        coverImage.backgroundColor = .yellow
//        titleLabel.backgroundColor = .orange
//        captionBar.backgroundColor = .cyan
//        backgroundColor = .magenta
#endif
    }
    
// MARK: - Subviews
    private lazy var verticalLayoutView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = sc.layoutGap

        return view
    }()

    private lazy var titledDevice: UIView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = sc.layoutGap
        view.addArrangedSubview(coverImageContainer)
        view.addArrangedSubview(titleLabel)
        
        return view
    }()

    private lazy var coverImageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(coverImage)
        NSLayoutConstraint.activate([
            coverImage.widthAnchor.constraint(equalToConstant: sc.coverImageSize(for: sizeClass)),
            coverImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            coverImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            coverImage.widthAnchor.constraint(equalTo: coverImage.heightAnchor),
        ])

        return view
    }()

    private lazy var coverImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = sizeClass.titleFont
        view.textColor = .label
        view.textAlignment = .center
        return view
    }()

    // Hidden by default
    private lazy var statusIconsBar: UIView = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        let text = NSMutableAttributedString()
        text.append(NSAttributedString.sfSymbol("thermometer.low") ?? .init())
        text.append(NSAttributedString.sfSymbol("battery.75percent") ?? .init())
        view.attributedText = text
        view.textAlignment = .center
        view.isHidden = true
        return view
    }()
    
    private lazy var captionBar: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = .preferredFont(forTextStyle: .body)
        view.textColor = .label
        view.font = sizeClass.captionFont
        view.textColor = .secondaryLabel
        view.textAlignment = .center
        view.adjustsFontSizeToFitWidth = true
        return view
    }()

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        sizeClass = .regular
        super.init(coder: coder)
    }
}

// MARK: - Convenience extensions
extension NSAttributedString {
    static func sfSymbol(_ name: String) -> NSAttributedString? {
        return UIImage(systemName: name).map { NSAttributedString(attachment: NSTextAttachment(image: $0)) }
    }
}

private extension UIDeviceStatusView.SizeClass {

    var titleFont: UIFont {
        switch self {
        case .large:
                .preferredFont(forTextStyle: .title3)
        case .regular:
                .preferredFont(forTextStyle: .callout)
        case .small:
                .preferredFont(forTextStyle: .caption1)
        }
    }
    var captionFont: UIFont {
        switch self {
        case .large:
                .preferredFont(forTextStyle: .callout)
        case .regular:
                .preferredFont(forTextStyle: .caption1)
        case .small:
                .preferredFont(forTextStyle: .caption2)
        }
    }
}
