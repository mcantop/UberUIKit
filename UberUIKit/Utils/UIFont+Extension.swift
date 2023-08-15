//
//  UIFont+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 14/08/2023.
//

import UIKit

extension UIFont {
    static func set(size: UIFont.TextStyle, weight: UIFont.Weight) -> UIFont {
        return .systemFont(ofSize: UIFont.preferredFont(forTextStyle: size).pointSize, weight: weight)
    }
}
