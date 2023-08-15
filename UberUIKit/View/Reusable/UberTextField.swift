//
//  UberTextField.swift
//  UberUIKit
//
//  Created by Maciej on 14/08/2023.
//

import UIKit

final class UberTextField: UITextField {
    init(placeholder: String, isSecure: Bool = false) {
        super.init(frame: .zero)
        
        borderStyle = .none
        isSecureTextEntry = isSecure
        font = .preferredFont(forTextStyle: .body)
        attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [NSAttributedString.Key.foregroundColor : UIColor.colorSchemeForegroundColor.withOpacity()]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
