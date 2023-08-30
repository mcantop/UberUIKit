//
//  LocationManager.swift
//  UberUIKit
//
//  Created by Maciej on 28/08/2023.
//

import CoreLocation

protocol LocationManagerDelegate: AnyObject {
    func presentLocationDeniedController()
    func updateUserLocation()
}

final class LocationManager: NSObject {
    static let shared = LocationManager()
    
    weak var delegate: LocationManagerDelegate?
    
    var location: CLLocation? {
        return manager.location
    }
    
    private var manager = CLLocationManager()
        
    override init() {
        super.init()
        
        manager.delegate = self
        
        enableLocationServices()
    }
}

// MARK: - Public API
extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
            // TODO: Investigate if it's possible to update user location only once in this flow (in both cases)
            delegate?.updateUserLocation()
        case .authorizedAlways:
            delegate?.updateUserLocation()
        case .notDetermined:
            break
        case .restricted, .denied:
            fallthrough
        @unknown default:
            delegate?.presentLocationDeniedController()
        }
    }
}

// MARK: - Private API
private extension LocationManager {
    func enableLocationServices() {
        switch manager.authorizationStatus {
        case .notDetermined:
            print("[DEBUG] Location Auth Status - Not Determined")
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            print("[DEBUG] Location Auth Status - Auth Always")
            manager.startUpdatingLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .authorizedWhenInUse:
            print("[DEBUG] Location Auth Status - Auth when In Use")
            manager.requestAlwaysAuthorization()
        case .restricted, .denied:
            fallthrough
        @unknown default:
            print("[DEBUG] Wrong Location Auth Status")
            delegate?.presentLocationDeniedController()
        }
    }
}
