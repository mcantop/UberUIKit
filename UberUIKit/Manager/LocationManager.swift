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
    func didEnterPickupRegion()
    func didEnterDestinationRegion()
}

enum AnnotationType: String {
    case pickup
    case destination
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
    
    func setCustomRegion(withType type: AnnotationType, coordinate: CLLocationCoordinate2D) {
        let region = CLCircularRegion(center: coordinate, radius: 25, identifier: type.rawValue)
        manager.startMonitoring(for: region)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            print("[DEBUG] Did start monitoring pick up region - \(region)")
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            print("[DEBUG] Did start monitoring destination region - \(region)")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == AnnotationType.pickup.rawValue {
            delegate?.didEnterPickupRegion()
        }
        
        if region.identifier == AnnotationType.destination.rawValue {
            delegate?.didEnterDestinationRegion()
        }
    }
}

// MARK: - Private API
private extension LocationManager {
    func enableLocationServices() {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedAlways:
            manager.startUpdatingLocation()
            manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .restricted, .denied:
            fallthrough
        @unknown default:
            delegate?.presentLocationDeniedController()
        }
    }
}
