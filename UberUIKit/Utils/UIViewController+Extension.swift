//
//  UIViewController+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import UIKit
import JGProgressHUD

extension UIViewController {
    func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        present(alert, animated: true)
    }
}
