//
//  HomeController.swift
//  UberUIKit
//
//  Created by Maciej on 26/08/2023.
//

import UIKit
import Firebase
import MapKit

protocol HomeControllerDelegate: AnyObject {
    func setupUI()
}

final class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUserLoggedIn() {
            setupUI()
        } else {
            presentLoginView()
        }
        
        signout()
    }
}

// MARK: - Private API
private extension HomeController {
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    func signout() {
        Task {
            try Auth.auth().signOut()
        }
    }
    
    func presentLoginView() {
        DispatchQueue.main.async {
            let loginController = LoginController()
            loginController.delegate = self
            
            let navigationController = UINavigationController(rootViewController: loginController)
            navigationController.modalPresentationStyle = .fullScreen
            
            self.present(navigationController, animated: true)
        }
    }
}

// MARK: - HomeControllerDelegate
extension HomeController: HomeControllerDelegate {
    func setupUI() {
        print("[DEBUG] Setup UI called")
        view.addSubview(mapView)
        mapView.frame = view.frame
    }
}
