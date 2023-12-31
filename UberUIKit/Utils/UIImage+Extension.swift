//
//  UIImage+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 13/08/2023.
//

import UIKit

typealias SFSymbol = UIImage.SFSymbol

extension UIImage {
    enum SFSymbol {
        enum Auth {
            static let email = UIImage(systemName: "envelope")
            static let password = UIImage(systemName: "lock")
            static let confirmPassword = UIImage(systemName: "lock.trianglebadge.exclamationmark")
            static let fullName = UIImage(systemName: "person")
        }
        
        static let car = UIImage(systemName: "car.side.fill")
        static let backArrow = UIImage(systemName: "arrow.left")
        static let hamburger = UIImage(systemName: "line.3.horizontal")
        static let xmark = UIImage(systemName: "xmark")
    }
    
    func style(color: UIColor = .colorSchemeForegroundColor, size: UIFont.TextStyle, weight: UIFont.Weight) -> UIImage {
        let config = UIImage.SymbolConfiguration(paletteColors: [color])
            .applying(UIImage.SymbolConfiguration(font: .set(size: size, weight: weight)))
        return self.withConfiguration(config).withRenderingMode(.alwaysTemplate)
    }
}
