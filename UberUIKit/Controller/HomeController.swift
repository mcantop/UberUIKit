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

private enum ActionButtonType {
    case hamburger
    case arrow
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
    private var searchResults = [MKPlacemark]()
    private var route: MKRoute?
    
    private lazy var locationInputActivationView = LocationInputActivationView()
    private lazy var locationInputView = LocationInputView()
    private lazy var tableView = UITableView()
    private lazy var actionButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
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
                
        if isUserLoggedIn {
            handleUserLoggedInFlow()
        } else {
            presentLoginView()
        }
    }
    
    @objc private func handleBackArrowTapped() {
        removeAnnotationsAndPolyline()
                
        styleActionButton(to: .hamburger)
        
        let userAnnotation = mapView.annotations.compactMap { $0 as? MKUserLocation }
        mapView.showAnnotations(userAnnotation, animated: true)
        
        dismiss()
    }
    
    @objc private func handleHamburgerTapped() {
        logout()
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
        setupActionButton()
        setupLocationInputActivationView()
        setupTableView()
    }
    
    func setupMapView() {
        view.addSubview(mapView)
        
        mapView.delegate = self
        mapView.frame = view.frame
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
    }
    
    func setupLocationInputActivationView() {
        styleActionButton(to: .hamburger)
        
        view.addSubview(locationInputActivationView)
        
        locationInputActivationView.delegate = self
        locationInputActivationView.alpha = .zero
        
        UIView.animate(withDuration: Constants.initialAnimationDuration) {
            self.locationInputActivationView.alpha = Constants.elementVisible
        }
        
        locationInputActivationView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            locationInputActivationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationInputActivationView.topAnchor.constraint(equalTo: actionButton.bottomAnchor, constant: 16),
            locationInputActivationView.widthAnchor.constraint(equalToConstant: view.frame.width - 32),
            locationInputActivationView.heightAnchor.constraint(equalToConstant: Constants.locationInputActivationViewHeight),
            
        ])
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .colorSchemeBackgroundColor
        tableView.register(LocationSearchResultCell.self, forCellReuseIdentifier: LocationSearchResultCell.reuseIdentifier)
        tableView.rowHeight = Constants.locationCellHeight
        
        let height = view.frame.height - Constants.locationInputViewHeight
        tableView.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: height
        )
    }
    
    func setupActionButton() {
        view.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        ])
    }
    
    func styleActionButton(to type: ActionButtonType) {
        let image = (type == .hamburger ? SFSymbol.hamburger : SFSymbol.backArrow)?
            .style(size: .headline, weight: .semibold)
        actionButton.setImage(image, for: .normal)

        switch type {
        case .hamburger:
            actionButton.removeTarget(self, action: #selector(handleBackArrowTapped), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(handleHamburgerTapped), for: .touchUpInside)
        case .arrow:
            actionButton.removeTarget(self, action: #selector(handleHamburgerTapped), for: .touchUpInside)
            actionButton.addTarget(self, action: #selector(handleBackArrowTapped), for: .touchUpInside)
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
    
    func dismissAfterSelectingAddress(completion: @escaping() -> Void) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.locationInputView.alpha = .zero
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview() /// For better performance, because we addSubview every time func is ran

            completion()
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
    
    func logout() {
        try? Auth.auth().signOut()
        
        presentLoginView()
    }
}

// MARK: - MapView Helpers
private extension HomeController {
    func searchBy(naturalLanguageQuery: String, completion: @escaping([MKPlacemark]) -> Void) {
        let request = MKLocalSearch.Request()
        request.region = mapView.region
        request.naturalLanguageQuery = naturalLanguageQuery
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response else { return }
            
            completion(response.mapItems.compactMap { $0.placemark })
        }
    }
    
    func generatePolyline(toDestination destination: MKMapItem) async {
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destination
        request.transportType = .automobile
        
        let directionRequest = MKDirections(request: request)
        let response = try? await directionRequest.calculate()
        route = response?.routes.first
        
        guard let polyline = route?.polyline else { return }
        mapView.addOverlay(polyline)
    }
    
    func removeAnnotationsAndPolyline() {
        mapView.annotations.forEach { annotation in
            if annotation is MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
        
        if !mapView.overlays.isEmpty {
            if let polyline = mapView.overlays.first {
                mapView.removeOverlay(polyline)
            }
        }
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
    func executeSearch(query: String) {
        searchBy(naturalLanguageQuery: query) { results in
            self.searchResults = results
            self.tableView.reloadData()
        }
    }
    
    func dismiss() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.alpha = .zero
            self.locationInputActivationView.alpha = Constants.elementVisible
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
        return section == 0 ? 2 : searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LocationSearchResultCell.reuseIdentifier, for: indexPath) as! LocationSearchResultCell
        cell.backgroundColor = .colorSchemeBackgroundColor
        if indexPath.section == 1 {
            cell.placemark = searchResults[indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        styleActionButton(to: .arrow)
                
        let placemark = self.searchResults[indexPath.row]
        let destination = MKMapItem(placemark: placemark)
        
        Task {
            await self.generatePolyline(toDestination: destination)
        }
        
        dismissAfterSelectingAddress {
            let annotation = MKPointAnnotation()
            annotation.coordinate = placemark.coordinate

            self.mapView.addAnnotation(annotation)
            self.mapView.selectAnnotation(annotation, animated: true)
            
            let annotations = self.mapView.annotations.filter { !$0.isKind(of: DriverAnnotation.self) }
            
            self.mapView.showAnnotations(annotations, animated: true)
        }
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
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route {
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(polyline: polyline)
            lineRenderer.strokeColor = .colorSchemeForegroundColor
            lineRenderer.lineWidth = 6
            return lineRenderer
        }
        
        return MKOverlayRenderer()
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
