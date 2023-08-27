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
    func handleUserLoggedInFlow()
}

final class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUserLoggedIn() {
            handleUserLoggedInFlow()
        } else {
            presentLoginView()
        }
        
//        signout()
    }
}

// MARK: - Private API
private extension HomeController {
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    func signout() {
        try? Auth.auth().signOut()
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
    
    func configureMapView() {
        view.addSubview(mapView)
        
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
    }
}

// MARK: - HomeControllerDelegate
extension HomeController: HomeControllerDelegate {
    func handleUserLoggedInFlow() {
        configureMapView()

        enableLocationServices()
    }
}

// MARK: - LocationServices && CLLocationManagerDelegate
extension HomeController: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestAlwaysAuthorization()
        case .authorizedAlways, .notDetermined:
            break
        case .restricted, .denied:
            fallthrough
        @unknown default:
            presentLocationDeniedController()
        }
    }
    
    private func enableLocationServices() {
        locationManager.delegate = self
        
        switch locationManager.authorizationStatus {
        case .notDetermined:
            print("[DEBUG] Location Auth Status - Not Determined")
            locationManager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("[DEBUG] Location Auth Status - Auth Always")
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .authorizedWhenInUse:
            print("[DEBUG] Location Auth Status - Auth when In Use")
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            fallthrough
        @unknown default:
            print("[DEBUG] Wrong Location Auth Status")
            presentLocationDeniedController()
        }
    }
    
    private func presentLocationDeniedController() {
        print("[DEBUG] Presenting Location Denied View Controller")
        navigationController?.pushViewController(LocationDeniedController(), animated: true)
    }
}
