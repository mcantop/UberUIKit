//
//  UIColor+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 13/08/2023.
//

import UIKit

typealias Uber = UIColor.Uber

enum OpacityType {
    case `default`
    case medium
    
    var value: CGFloat {
        switch self {
        case .default:
            return 0.75
        case .medium:
            return 0.5
        }
    }
}

extension UIColor {
    enum Uber {
        enum Background {
            static let dark = UIColor.init(red: 25/255, green: 25/255, blue: 25/255, alpha: 1)
            static let light = UIColor.init(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
        }
    }
    
    static var colorSchemeForegroundColor: UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? .white : .black }
    }
    
    static var colorSchemeBackgroundColor: UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? Uber.Background.dark : Uber.Background.light }
    }
    
    static var colorSchemeShadowColor: UIColor {
        return UIColor { $0.userInterfaceStyle == .dark ? .darkGray : .black }
    }
    
    func withOpacity(_ type: OpacityType = .default) -> UIColor {
        return withAlphaComponent(type.value)
    }
}
