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

private enum Constants {
    static let initialAnimationDuration = 1.0
    static let animationDuration = 0.5
    static let elementVisible = 1.0
    static let locationInputActivationViewHeight = 50.0
    static let locationInputViewHeight: CGFloat = 200
    static let locationCellHeight = 60.0
}

final class HomeController: UIViewController {
    // MARK: - Properties
    private let mapView = MKMapView()
    private let locationManager = CLLocationManager()
    private let authService = AuthService.shared
    
    private lazy var locationInputActivationView = LocationInputActivationView()
    private lazy var locationInputView = LocationInputView()
    private lazy var tableView = UITableView()
    
    private var isUserLoggedIn: Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    private var user: User? {
        didSet {
            locationInputView.setFullNameLabel(user?.fullName)
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUserLoggedIn {
            handleUserLoggedInFlow()
        } else {
            presentLoginView()
        }
        
        //        signout()
    }
}

// MARK: - HomeControllerDelegate
extension HomeController: HomeControllerDelegate {
    func handleUserLoggedInFlow() {
        setupUI()
        enableLocationServices()
        fetchUserData()
    }
}

// MARK: - Private API
private extension HomeController {
    func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        setupMapView()
        setupLocationInputActivationView()
        setupTableView()
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func setupLocationInputActivationView() {
        view.addSubview(locationInputActivationView)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = .zero
        
        UIView.animate(withDuration: Constants.initialAnimationDuration) {
            self.locationInputActivationView.alpha = Constants.elementVisible
        }
        
        locationInputActivationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationInputActivationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationInputActivationView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            locationInputActivationView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            locationInputActivationView.heightAnchor.constraint(equalToConstant: Constants.locationInputActivationViewHeight),
            
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .colorSchemeBackgroundColor
        tableView.register(LocationCell.self, forCellReuseIdentifier: LocationCell.reuseIdentifier)
        tableView.rowHeight = Constants.locationCellHeight
        
        let height = view.frame.height - Constants.locationInputViewHeight
        tableView.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: height
        )
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
    
    func fetchUserData() {
        Task {
            self.user = try await authService.loadUserData()
        }
    }
    
    func signout() {
        try? Auth.auth().signOut()
    }
}


// MARK: - LocationInputActivationViewDelegate
extension HomeController: LocationInputActivationViewDelegate {
    func presentLocationInputView() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.locationInputActivationView.alpha = .zero
        }
        
        setupLocationInputView()
    }
    
    private func setupLocationInputView() {
        view.addSubview(locationInputView)
        
        locationInputView.delegate = self
        locationInputView.alpha = .zero
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.locationInputView.alpha = Constants.elementVisible
            self.tableView.frame.origin.y = Constants.locationInputViewHeight
        }
        
        locationInputView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            locationInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            locationInputView.heightAnchor.constraint(equalToConstant: Constants.locationInputViewHeight)
        ])
    }
}

// MARK: - LocationInputViewDelegate
extension HomeController: LocationInputViewDelegate {
    func dismissView() {
        
        UIView.animate(withDuration: Constants.animationDuration) {
            self.locationInputView.alpha = .zero
            self.locationInputActivationView.alpha = Constants.elementVisible
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview() /// For better performance, because we addSubview every time func is ran
        }
    }
}

// MARK: - UITableViewDelegate && UITableViewDataSource
extension HomeController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Section Header Title"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationCell.reuseIdentifier, for: indexPath) as! LocationCell
        cell.backgroundColor = .colorSchemeBackgroundColor
        return cell
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
        navigationController?.pushViewController(LocationDeniedController(), animated: true)
    }
}
