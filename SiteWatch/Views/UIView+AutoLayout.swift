//
//  UIView+AutoLayout.swift
//  SiteWatch
//
//  Created by Simon Kim on 11/11/23.
//

import Foundation
import UIKit

extension UIView {
    func pinEdges(to other: UIView, border: CGFloat = 0) {
        leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: border).isActive = true
        trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -border).isActive = true
        topAnchor.constraint(equalTo: other.topAnchor, constant: border).isActive = true
        bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -border).isActive = true
    }
}
