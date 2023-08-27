//
//  JGProgressHUD+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 27/08/2023.
//

import Foundation
import JGProgressHUD

final class UberLoadingIndicator {
    private static var hud: JGProgressHUD = {
        return .init()
    }()
    
    static func show(in view: UIView) {
        resetProperties()
        
        hud.show(in: view, animated: true)
    }
    
    static func displaySuccess() async {
        DispatchQueue.main.async {
            self.hud.indicatorView =  JGProgressHUDSuccessIndicatorView()
            self.hud.textLabel.text = "Success!"
        }
        
        await hud.dismiss(afterDelay: 0.5, animated: true)
    }
    
    static func displaFail() async {
        DispatchQueue.main.async {
            self.hud.indicatorView = JGProgressHUDErrorIndicatorView()
            self.hud.textLabel.text = "Fail.."
        }
        
        await hud.dismiss(afterDelay: 0.5, animated: true)
    }
    
    static private func resetProperties() {
        hud.indicatorView = JGProgressHUDIndeterminateIndicatorView()
        hud.textLabel.text = ""
    }
}
