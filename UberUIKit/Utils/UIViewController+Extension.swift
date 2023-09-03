//
//  UIViewController+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import UIKit
import JGProgressHUD

private enum Constants {
    static let animationDuration = 0.5
    static let elementVisible = 0.87
}

extension UIViewController {
    func presentErrorAlert(_ error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .default))
        present(alert, animated: true)
    }
    
    func showLoadingView(_ show: Bool, message: String? = nil) {
        if show {
            let loadingView = UIView()
            loadingView.frame = self.view.frame
            loadingView.backgroundColor = .colorSchemeBackgroundColor
            loadingView.alpha = .zero
            loadingView.tag = 1
            
            let indicatorView = UIActivityIndicatorView(style: .large)
            indicatorView.center = loadingView.center
            indicatorView.startAnimating()
            
            let loadingMessage = UILabel()
            loadingMessage.text = message
            loadingMessage.font = .set(size: .headline, weight: .semibold)
            loadingMessage.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(loadingView)
            loadingView.addSubview(indicatorView)
            loadingView.addSubview(loadingMessage)
            
            NSLayoutConstraint.activate([
                loadingMessage.topAnchor.constraint(equalTo: indicatorView.bottomAnchor, constant: 16),
                loadingMessage.centerXAnchor.constraint(equalTo: view.centerXAnchor)
            ])
            
            UIView.animate(withDuration: Constants.animationDuration) {
                loadingView.alpha = Constants.elementVisible
                loadingMessage.alpha = Constants.elementVisible
                indicatorView.alpha = Constants.elementVisible
            }
        } else {
            for subview in view.subviews where subview.tag == 1 {
                UIView.animate(withDuration: Constants.animationDuration) {
                    subview.alpha = .zero
                } completion: { _ in
                    subview.removeFromSuperview()
                }
            }
        }
    }
}
