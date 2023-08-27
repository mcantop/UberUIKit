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
        
        static let leftArrow = UIImage(systemName: "arrow.left")
    }
}
