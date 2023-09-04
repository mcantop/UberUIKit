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
    func didEnterRiderRegion()
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

// MARK: - CLLocationManagerDelegate
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
    
    func setCustomRegion(coordinate: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinate, radius: 25, identifier: "pickup")
        manager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("[DEBUG] Did start monitoring for region")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("[DEBUG] Driver did enter passenger region")
        delegate?.didEnterRiderRegion()
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
