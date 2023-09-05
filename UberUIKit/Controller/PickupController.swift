//
//  PickupController.swift
//  UberUIKit
//
//  Created by Maciej on 02/09/2023.
//

import UIKit
import MapKit

protocol PickupControllerDelegate: AnyObject {
    func didAcceptRide(_ ride: Ride)
}

private enum Constants {
    static let mapViewSize = 270.0
    static let padding = 16.0
    static let mapViewPadding = 64.0
    static let mapViewRangeInMeters = 1000.0
}

final class PickupController: UIViewController {
    // MARK: - Properties
    weak var deleagte: PickupControllerDelegate?
    
    private let ride: Ride
    private let locationService: LocationService
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        let image = SFSymbol.xmark?
            .style(size: .headline, weight: .semibold)
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.layer.cornerRadius = Constants.mapViewSize / 2
        return mapView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = "Would you like to pick up this passenger?"
        label.font = .set(size: .headline, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var acceptButton: UIButton = {
        let button = UberWideButton(type: .system)
        button.setTitle("Accept Ride", for: .normal)
        button.applyStyling()
        button.addTarget(self, action: #selector(handleAcceptRide), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Lifecycle
    init(ride: Ride, locationService: LocationService) {
        self.ride = ride
        self.locationService = locationService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupConstraints()
    }
    
    // MARK: - Selectors
    @objc private func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc private func handleAcceptRide() {
        locationService.acceptRide(ride) {
            self.deleagte?.didAcceptRide(self.ride)
        }
    }
}

// MARK: - Private API
extension PickupController {
    func setupUI() {
        view.backgroundColor = .colorSchemeBackgroundColor.withAlphaComponent(0.87)
        
        view.addSubview(cancelButton)
        view.addSubview(mapView)
        view.addSubview(label)
        view.addSubview(acceptButton)
        
        setupMapView()
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Constants.padding),
            cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            
            mapView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            mapView.topAnchor.constraint(equalTo: cancelButton.bottomAnchor, constant: Constants.mapViewPadding),
            mapView.widthAnchor.constraint(equalToConstant: Constants.mapViewSize),
            mapView.heightAnchor.constraint(equalToConstant: Constants.mapViewSize),
            mapView.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -Constants.mapViewPadding),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
            
            acceptButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: Constants.padding),
            acceptButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Constants.padding),
            acceptButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Constants.padding),
        ])
    }
    
    func setupMapView() {
        let coordinate = CLLocationCoordinate2D(
            latitude: ride.pickupCoordinate.latitude,
            longitude: ride.pickupCoordinate.longitude
        )
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: Constants.mapViewRangeInMeters,
            longitudinalMeters: Constants.mapViewRangeInMeters
        )
        
        mapView.setRegion(region, animated: true)
        
        self.mapView.addAndSelectAnnotation(forCoordinate: coordinate)
    }
}
