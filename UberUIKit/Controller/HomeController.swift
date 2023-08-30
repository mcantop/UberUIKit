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
    private let service = Service.shared
    private let authService = AuthService.shared
    private let locationService = LocationService.shared
    private var locationManager: LocationManager?
    
    private lazy var locationInputActivationView = LocationInputActivationView()
    private lazy var locationInputView = LocationInputView()
    private lazy var tableView = UITableView()
    private lazy var logoutButton = UIButton(type: .system)
    
    private var isUserLoggedIn: Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    private var user: User? {
        didSet {
            locationInputView.setFullNameLabel(user?.fullName)

            updateUserLocation()
        }
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        signout()
        
        if isUserLoggedIn {
            handleUserLoggedInFlow()
        } else {
            presentLoginView()
        }
    }
    
    @objc private func handleSignout() {
        signout()
    }
}

// MARK: - HomeControllerDelegate
extension HomeController: HomeControllerDelegate {
    func handleUserLoggedInFlow() {
        locationManager = LocationManager.shared
        locationManager?.delegate = self
        
        setupUI()
        loadUserData()
        loadNearbyDrivers()
    }
}

// MARK: - Private API
private extension HomeController {
    func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        setupMapView()
        setupLocationInputActivationView()
        setupTableView()
        setupLogoutButton()

    }
    
    func setupLogoutButton() {
        view.addSubview(logoutButton)
        
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.addTarget(self, action: #selector(handleSignout), for: .touchUpInside)
        
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -48)
        ])
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        
        mapView.delegate = self
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
    
    func loadUserData() {
        Task {
            user = try await service.loadUserData()
        }
    }
    
    func loadNearbyDrivers() {
        locationService.loadNearbyDrivers(for: locationManager?.location) { drivers in
            for driver in drivers {
                guard let latitude = driver.location?.latitude,
                      let longitude = driver.location?.longitude else { return }
                let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let annotation = DriverAnnotation(uid: driver.id, coordinate: coordinate)
                
                var isAnnotationVisible: Bool {
                    for annotation in self.mapView.annotations {
                        if
                            let driverAnnotation = annotation as? DriverAnnotation,
                            driverAnnotation.uid == driver.id
                        {
                            print("[DEBUG] Updating annotation for Driver - \(driver.fullName)")
                            driverAnnotation.updateAnnotation(withNewCoordinate: coordinate)
                            return true
                        }
                    }
                    return false
                }
                
                if !isAnnotationVisible {
                    self.mapView.addAnnotation(annotation)
                } else {
                    
                }
            }
        }
    }
    
    func signout() {
        try? Auth.auth().signOut()
        
        presentLoginView()
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

// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? DriverAnnotation else { return nil }
        
        let view = MKAnnotationView(annotation: annotation, reuseIdentifier: DriverAnnotation.reuseIdentifier)
        view.image = SFSymbol.car?.style(size: .title2, weight: .black)
        return view
    }
}

// MARK: -  LocationManagerDelegate
extension HomeController: LocationManagerDelegate {
    func presentLocationDeniedController() {
        navigationController?.pushViewController(LocationDeniedController(), animated: true)
    }
    
    func updateUserLocation() {
        Task {
             await locationService.updateUserLocation(
                user: user,
                coordinate: locationManager?.location?.coordinate
            )
        }
    }
}
