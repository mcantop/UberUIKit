//
//  LocationService.swift
//  UberUIKit
//
//  Created by Maciej on 29/08/2023.
//

import CoreLocation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import GeoFirestore

struct LocationService {
    static let shared = LocationService()
    
    private let service = Service()
}

// MARK: - Public API
extension LocationService {
    func updateUserLocation(user: User?, coordinate: CLLocationCoordinate2D?) async {
        guard var user,
              let coordinate else { return }
        
        user.location = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        user.lastLogin = Timestamp(date: .now)
        
        do {
            try await service.uploadUserData(user)
            print("[DEBUG] Updated user location")
        } catch {
            print("[DEBUG] updateUserLocation error - \(error.localizedDescription)")
        }
    }
    
    func loadNearbyDrivers(for location: CLLocation?, completion: @escaping ([User]) -> Void) {
        loadNearbyDrivers(location: location, distance: 1) { completion($0) }
    }
    
    func uploadRide(pickupCoordinate: GeoPoint, destinationCoordinate: GeoPoint) {
        guard let passengerId = Auth.auth().currentUser?.uid else { return }
        
        let ride = Ride(
            passengerId: passengerId,
            pickupCoordinate: pickupCoordinate,
            destinationCoordinate: destinationCoordinate
        )
        
        do {
            try ServiceConstants.ridesCollection.addDocument(from: ride)
        } catch {
            print("[DEBUG] Error while uploading ride - \(error.localizedDescription)")
        }
    }
}

// MARK: - Private API
private extension LocationService {
    func loadNearbyDrivers(location: CLLocation?, distance: Double, completion: @escaping ([User]) -> Void) {
        guard let latitude = location?.coordinate.latitude.magnitude,
              let longitude = location?.coordinate.longitude.magnitude else { return }
        
        /// Converters
        let lat = 0.009
        let lon = 0.0001

        let lowerLat = latitude - (lat * distance)
        let lowerLon = longitude - (lon * distance)
        
        let greaterLat = latitude + (lat * distance)
        let greaterLon = longitude + (lon * distance)
        
        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        
        let docRef = ServiceConstants.usersCollection
        let query = docRef
            .whereField("location", isGreaterThan: lesserGeopoint)
            .whereField("location", isLessThan: greaterGeopoint)
            .whereField("accountType", isEqualTo: 1)
                
        query.addSnapshotListener { snapshot, _ in
            guard let snapshot else { return }
            completion(snapshot.documents.compactMap { try? $0.data(as: User.self) })
        }
    }
}
