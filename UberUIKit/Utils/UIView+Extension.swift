//
//  UIView+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 13/08/2023.
//

import UIKit

extension UIView {
    func setColorSchemeBackgroundColor() {
        backgroundColor = UIColor.colorSchemeBackgroundColor
    }
    
    func addShadow() {
        layer.shadowColor = UIColor.colorSchemeShadowColor.cgColor
        layer.shadowOpacity = 0.66
        layer.shadowOffset = CGSize(width: 0.5, height: 0.5)
    }
    
    func createPaddingView(spacing: CGFloat) -> UIView {
        let paddingView = UIView()
        paddingView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            paddingView.widthAnchor.constraint(equalToConstant: spacing)
        ])
        return paddingView
    }
}
