//
//  VerticalSeparatorView.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

class VerticalSeparatorView: UIView {
    private static let separatorHeightScale: CGFloat = 0.6
    private static let separatorColor: UIColor = .systemGray
    private static let separatorThickness: CGFloat = 1
    
    init(color: UIColor = separatorColor,
                              thickness: CGFloat = separatorThickness,
                              separatorHeightScale: CGFloat = separatorHeightScale) {
        super.init(frame: .zero)
        
        let vline = UIView()
        vline.translatesAutoresizingMaskIntoConstraints = false
        vline.backgroundColor = color
        
        addSubview(vline)
        NSLayoutConstraint.activate([
            vline.widthAnchor.constraint(equalToConstant: thickness),
            vline.widthAnchor.constraint(equalTo: widthAnchor),
            vline.heightAnchor.constraint(equalTo: heightAnchor, multiplier: separatorHeightScale),
            vline.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
