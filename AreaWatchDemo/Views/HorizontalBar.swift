//
//  HorizontalBar.swift
//  AreaWatchDemo
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

/// A bar layout with fixed witdth and number of of contained subviews.
/// Vertical separators are `systemGray` colored by default can also
/// be opted out by specifying `.clear` color
class HorizontalBar: UIView {
    /// Designated initializer.
    /// - Parameters:
    ///   - subviews: Fixed number of subviews to be horizontally  layed out
    ///   - separatorColor: Color of the separator between subviews. To disable, pass `.clear`
    init(subviews: [UIView], separatorColor: UIColor = .systemGray, evenWidth: Bool = false) {
        super.init(frame: .zero)

        guard !subviews.isEmpty else {
            // Empty subviews? Must be a mistake
            return
        }

        let separators = (0 ..< (subviews.count - 1)).map { _ in
            VerticalSeparatorView(color: separatorColor)
        }

        addSubview(horizontalLayoutView)
        horizontalLayoutView.pinEdges(to: self, border: sc.borderMargin)
        
        (zip(subviews, separators).flatMap { [$0, $1] } + subviews.suffix(from: separators.count))
        .forEach {
            horizontalLayoutView.addArrangedSubview($0)
        }

        separators.forEach {
            $0.heightAnchor.constraint(equalTo: horizontalLayoutView.heightAnchor).isActive = true
        }
        
        if evenWidth {
            let first = subviews.first!
            subviews
                .filter { $0 != first }
                .forEach {
                    $0.widthAnchor.constraint(equalTo: first.widthAnchor).isActive = true
                }
        }

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private let sc = StyleConfig()
    
    private lazy var horizontalLayoutView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .horizontal
        view.alignment = .center
        view.spacing = sc.layoutGap
        view.distribution = .fill
        return view
    }()
}

extension HorizontalBar {
    struct StyleConfig: GlobalStyleConfig {
    }
}

@available(iOS 17.0, *)
#Preview {
    let subviews: [UIView] = [
        {   let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "Hello"
            view.textAlignment = .center
            return view }(),
        {   let view = UILabel()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.text = "World"
            view.textAlignment = .center
            return view }(),
    ]

    return HorizontalBar(subviews: subviews)
}
