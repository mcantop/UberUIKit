//
//  UberWideButton.swift
//  UberUIKit
//
//  Created by Maciej on 14/08/2023.
//

import UIKit

final class UberWideButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applyStyling() {
        setTitleColor(.white, for: .normal)
        backgroundColor = .systemBlue
        titleLabel?.font = .set(size: .title3, weight: .semibold)
        layer.cornerRadius = 5
        heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
}
