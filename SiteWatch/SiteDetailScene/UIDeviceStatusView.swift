//
//  UIDeviceStatusView.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/10/23.
//

import Foundation
import UIKit

@available(iOS 17.0, *)
#Preview {
    let view = UIDeviceStatusView(.small)
    view.viewModel = DeviceDetailStatusViewModel(
        coverImage: .thermometer,
        title: "Sensor",
        // status: [...],
        caption: "Updated 12:31 AM",
        vitalStatus: [
            .init(deviceType: .connectivity, level: .medium),
            .init(deviceType: .battery, level: .high),
        ]
    )

    view.heightAnchor.constraint(equalToConstant: 150).isActive = true
    view.widthAnchor.constraint(equalToConstant: 100).isActive = true
    return view
}

// MARK: -

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
    typealias ViewModel = DeviceDetailStatusViewModel
    enum SizeClass {
        case small
        case regular
        case large
    }
    
    private let sc: StyleConfig = StyleConfig()
    private var currentVitalStatus: [DeviceVital] = []
    
    var viewModel: ViewModel = .empty {
        didSet {
            if titleLabel.text != viewModel.title {
                titleLabel.animatedUpdate { [weak self] view in
                    (view as! UILabel).text = self?.viewModel.title
                }
            }
            titleLabel.highlightChange(text: viewModel.title)
            captionBar.highlightChange(text: viewModel.caption)
            coverImage.image = viewModel.coverImage
            statusIconsBar.isHidden = !viewModel.isStatusIconsBarVisible
            if viewModel.isStatusIconsBarVisible {
                if currentVitalStatus != viewModel.vitalStatus {
                    // Compare change in viewModel.vitalStatus instead of \.attributedText
                    statusIconsBar.highlightChange(attributedText: makeStatusIconsBarText(with: viewModel.vitalStatus))
                    currentVitalStatus = viewModel.vitalStatus
                }
            }

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
#endif
    }
    
    private func makeStatusIconsBarText(with vitals: [DeviceVital]) -> NSAttributedString {
        let text = NSMutableAttributedString()
        vitals
            .compactMap { $0.deviceType.uiImage(level: $0.level) }
            .map {
                NSAttributedString(
                    attachment: NSTextAttachment(image: $0)
                )
            }.forEach {
                text.append($0)
            }
        return text
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
    private lazy var statusIconsBar: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
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

extension UIView {
    func animatedUpdate(_ update: @escaping (UIView) -> Void) {
        let originalTransform = self.transform
        UIView.transition(with: self,
                          duration: 0.2,
                          options: .curveEaseInOut,
                          animations: {
            self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            update(self)
        }, completion: {_ in self.transform = originalTransform})
    }
}

extension UILabel {
    func highlightChange(text: String) {
        guard self.text != text else { return }
        animatedUpdate { view in
            (view as! UILabel).text = text
        }
    }
    
    func highlightChange(attributedText: NSAttributedString) {
        guard self.text != attributedText.string else { return }
        animatedUpdate { view in
            (view as! UILabel).attributedText = attributedText
        }
    }
}
