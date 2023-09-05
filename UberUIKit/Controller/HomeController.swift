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
    static let locationInputViewHeight = 200.0
    static let locationCellHeight = 60.0
    static let rideActionViewHeight = 270.0
    static let actionButtonImagePadding = 8.0
    static let mapViewRangeInMeters = 1000.0
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
    private lazy var rideActionView = RideActionView()
    private lazy var tableView = UITableView()
    private lazy var actionButton = UIButton(type: .system)
    
    private var isUserLoggedIn: Bool {
        return Auth.auth().currentUser?.uid != nil
    }
    
    private var isCurrentUserRider: Bool {
        return user?.accountType == .rider
    }
    
    private var currentUserType: AccountType? {
        return user?.accountType
    }
    
    private var user: User? {
        didSet {
            locationInputView.setFullNameLabel(user?.fullName)
            
            updateUserLocation()
        }
    }
    
    private var ride: Ride? {
        didSet {
            if isCurrentUserRider {
                // TODO:
            } else {
                presentPickupView()
            }
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
        
        dismissLocationInputView()
        
        presentRideActionView(false)
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
        
        loadUserData {
            if self.isCurrentUserRider {
                self.observeNearbyDrivers()
            } else {
                self.observeRides()
            }
            
            self.setupUI()
        }
    }
}

// MARK: - Private API
private extension HomeController {
    func setupUI() {
        navigationController?.isNavigationBarHidden = true
        
        setupMapView()
        setupActionButton()
                
        if isCurrentUserRider {
            setupLocationInputActivationView()
        }
        
        setupTableView()
        setupRideActionView()
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
        styleActionButton(to: .hamburger)
        
        view.addSubview(actionButton)
        
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            actionButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            actionButton.heightAnchor.constraint(equalToConstant: Constants.locationInputActivationViewHeight)
        ])
    }
    
    func setupRideActionView() {
        view.addSubview(rideActionView)
        
        rideActionView.delegate = self
        rideActionView.userType = user?.accountType
        
        rideActionView.frame = CGRect(
            x: 0,
            y: view.frame.height,
            width: view.frame.width,
            height: Constants.rideActionViewHeight
        )
    }
    
    func presentRideActionView(_ show: Bool, type: RideActionViewType? = nil, destination: MKPlacemark? = nil) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.rideActionView.frame.origin.y = show
            ? self.view.frame.height - Constants.rideActionViewHeight
            : self.view.frame.height
        }
        
        if let destination {
            rideActionView.placemark = destination
        }
        
        if let type {
            rideActionView.actionType = type
        }
    }
    
    func styleActionButton(to type: ActionButtonType) {
        let image = (type == .hamburger ? SFSymbol.hamburger : SFSymbol.backArrow)?
            .style(size: .headline, weight: .semibold)
        
        var configuration: UIButton.Configuration = .filled()
        configuration.image = image
        configuration.imagePadding = Constants.actionButtonImagePadding
        configuration.baseBackgroundColor = .colorSchemeBackgroundColor
        configuration.background.cornerRadius = 0
        
        actionButton.configuration = configuration
        actionButton.layer.cornerRadius = 0
        actionButton.addShadow()
        
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
    
    func presentPickupView() {
        guard let ride else { return }
        
        let controller = PickupController(ride: ride, locationService: locationService)
        controller.modalPresentationStyle = .custom
        controller.deleagte = self
        
        present(controller, animated: true)
    }
    
    func dismissLocationInputView(completion: @escaping() -> Void) {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.locationInputView.alpha = .zero
            self.tableView.frame.origin.y = self.view.frame.height
        } completion: { _ in
            self.locationInputView.removeFromSuperview() /// For better performance, because we addSubview every time func is ran
            
            completion()
        }
    }
    
    func loadUserData(completion: @escaping() -> Void) {
        Task {
            user = try await service.loadCurrentUserData()
            
            completion()
        }
    }
    
    func observeNearbyDrivers() {
        locationService.observeNearbyDrivers(for: locationManager?.location) { drivers in
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
                            driverAnnotation.updateAnnotation(withNewCoordinate: coordinate)
                            
                            if self.ride != nil { /// Zoom only when ride is in progress
                                self.zoomForCurrentRide()
                            }
                            
                            return true
                        }
                    }
                    return false
                }
                
                if !isAnnotationVisible {
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    
    func zoomForCurrentRide() {
        guard let currentRide = ride else { return }
        
        var annotations = [MKAnnotation]()
        
        mapView.annotations.forEach { annotation in
            if let riderAnnotation = annotation as? MKUserLocation {
                annotations.append(riderAnnotation)
            }
            
            if let driverAnnotation = annotation as? DriverAnnotation, driverAnnotation.uid == currentRide.driverId {
                annotations.append(driverAnnotation)
            }
        }
        
        mapView.zoomToFit(annotation: annotations, rideActionViewHeight: Constants.rideActionViewHeight)
    }
    
    func observeRides() {
        locationService.observeRides { ride in
            self.ride = ride
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
    
    func updateUIAfterRideWasCancelled() {
        presentRideActionView(false)
        removeAnnotationsAndPolyline()
        styleActionButton(to: .hamburger)
        centerMapOnUserLocation()
        presentAlert(
            title: "Ride Cancelled",
            message: "Your ride has been cancelled."
        )
        
        if isCurrentUserRider {
            setupLocationInputActivationView()
        }
        
        rideActionView.secondUserName = nil
    }
    
    func centerMapOnUserLocation() {
        guard let coordinate = locationManager?.location?.coordinate else { return }
        
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: Constants.mapViewRangeInMeters,
            longitudinalMeters: Constants.mapViewRangeInMeters
        )
        
        mapView.setRegion(region, animated: true)
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
    
    func dismissLocationInputView() {
        UIView.animate(withDuration: Constants.animationDuration) {
            self.tableView.frame.origin.y = self.view.frame.height
            self.locationInputView.alpha = .zero
            self.locationInputActivationView.alpha = Constants.elementVisible
        } completion: { _ in
            self.locationInputView.removeFromSuperview() /// For better performance, because we addSubview every time func is ran
        }
    }
}

// MARK: - RideActionViewDelegate
extension HomeController: RideActionViewDelegate {
    func pickupPassenger() {
        guard let ride,
              let rideid = ride.id else { return }
        
        Task {
            await locationService.updateRideState(rideId: rideid, toState: .inProgress)
            
            rideActionView.actionType = .inProgress(currentUserType)
            
            removeAnnotationsAndPolyline()
            
            let destinationCoordinate = ride.destinationCoordinate.asCoordinate2D
            let placemark = MKPlacemark(coordinate: destinationCoordinate)
            let mapItem = MKMapItem(placemark: placemark)
            
            mapView.addAndSelectAnnotation(forCoordinate: destinationCoordinate)
            
            await generatePolyline(toDestination: mapItem)
        }
    }
    
    func cancelRide() {
        Task {
            await locationService.cancelRide(ride?.id)
            
            self.ride = nil /// Needed for stopping showing user his driver after trip has been cancelled
            
            updateUIAfterRideWasCancelled()
        }
    }
    
    func confirmRide() {
        guard let pickupLatitude = locationManager?.location?.coordinate.latitude,
              let pickupLongitude = locationManager?.location?.coordinate.longitude,
              let destinationLatitude = rideActionView.placemark?.coordinate.latitude,
              let destinationLongitude = rideActionView.placemark?.coordinate.longitude else { return }
        
        showLoadingView(true, message: "Finding you a perfect ride..")
        
        let pickupCoordinate = GeoPoint(latitude: pickupLatitude, longitude: pickupLongitude)
        let destinationCoordinate = GeoPoint(latitude: destinationLatitude, longitude: destinationLongitude)
        
        guard let ride = locationService.confirmRide(
            pickupCoordinate: pickupCoordinate,
            destinationCoordinate: destinationCoordinate
        ) else { return }
        
        locationService.observeCurrentRideForRider(ride) { ride in
            self.ride = ride
            
            print("[DEBUG] Ride State - \(ride.state)")
            guard let driverId = ride.driverId else { return }
                        
            switch ride.state {
            case .requested:
                break
            case .accepted:
                guard self.rideActionView.secondUserName == nil else { break }
                self.removeAnnotationsAndPolyline()
                self.zoomForCurrentRide()
                
                Task {
                    let driver = try? await self.service.loadUserData(uid: driverId)
                    
                    self.rideActionView.secondUserName = driver?.fullName
                    self.showLoadingView(false)
                    self.presentRideActionView(true, type: .accepted(self.user?.accountType))
                }
            case .driverArrived:
                self.rideActionView.actionType = .driverArrived
            case .inProgress:
                self.rideActionView.actionType = .inProgress(self.currentUserType)
            case .completed:
                break
            }
        }
        
        presentRideActionView(false)
    }
}

// MARK: - PickupControllerDelegate
extension HomeController: PickupControllerDelegate {
    func didAcceptRide(_ ride: Ride) {
        let pickupCoordinate = ride.pickupCoordinate.asCoordinate2D
        
        mapView.addAndSelectAnnotation(forCoordinate: pickupCoordinate)
        
        locationManager?.setCustomRegion(coordinate: pickupCoordinate)
        
        Task {
            let placemark = MKPlacemark(coordinate: ride.pickupCoordinate.asCoordinate2D)
            let mapItem = MKMapItem(placemark: placemark)
            
            await self.generatePolyline(toDestination: mapItem)
            
            mapView.zoomToFit(annotation: mapView.annotations, rideActionViewHeight: Constants.rideActionViewHeight)
            
            let rider = try? await service.loadUserData(uid: ride.passengerId)
            rideActionView.secondUserName = rider?.fullName
            
            dismiss(animated: true) {
                self.presentRideActionView(true, type: .accepted(self.user?.accountType))
            }
            
            locationService.observeIfCurrentRideIsCancelled(ride.id) {
                self.updateUIAfterRideWasCancelled()
            }
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
        
        dismissLocationInputView {
            self.mapView.addAndSelectAnnotation(forCoordinate: placemark.coordinate)
            
            let annotations = self.mapView.annotations.filter { !$0.isKind(of: DriverAnnotation.self) }
            self.mapView.zoomToFit(annotation: annotations, rideActionViewHeight: Constants.rideActionViewHeight)
            self.presentRideActionView(true, type: .requested, destination: placemark)
        }
    }
}

// MARK: - MKMapViewDelegate
extension HomeController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        /// Update location only for the driver, so rider can see driver being updated
        guard let user, user.accountType == .driver else { return }
        
        Task {
            await locationService.updateUserLocation(
                user: user,
                coordinate: userLocation.location?.coordinate
            )
        }
    }
    
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
    func didEnterRiderRegion() {
        Task {
            guard let rideId = ride?.id else { return }
            
            await locationService.updateRideState(rideId: rideId, toState: .driverArrived)
            
            rideActionView.actionType = .pickupPassenger
        }
    }
    
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
