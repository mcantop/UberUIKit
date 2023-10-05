//
//  ContainerController.swift
//  UberUIKit
//
//  Created by Maciej on 05/10/2023.
//

import UIKit

final class ContainerController: UIViewController {
    // MARK: - Properties
    private lazy var homeController = HomeController()
    private lazy var menuController = MenuController()
    private var presentingMenu = false
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    // MARK: - Selectors
}

// MARK: - HomeControllerDelegate
extension ContainerController: HomeControllerDelegate {
    func handleMenuToggle() {
        animateMenu()
    }
}

// MARK: - Private API
private extension ContainerController {
    func setupUI() {
        addChild(homeController)
        
        homeController.didMove(toParent: self)
        homeController.delegate = self
        
        view.addSubview(homeController.view)
    }
    
    func setupMenuController() {
        addChild(menuController)
        
        menuController.didMove(toParent: self)
        
        view.insertSubview(menuController.view, at: 0)
    }
    
    func animateMenu() {
        presentingMenu.toggle()
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0,
            options: .curveEaseInOut
        ) {
            self.homeController.view.frame.origin.x = self.presentingMenu ? self.view.frame.width - 80 : .zero
        }
    }
}
