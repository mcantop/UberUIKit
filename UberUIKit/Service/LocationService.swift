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

struct LocationService {
    static let shared = LocationService()
    
    private let service = Service()
    
    func updateUserLocation(user: User?, coordinate: CLLocationCoordinate2D?) async {
        guard var user,
              let coordinate else { return }
        
        user.location = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        await service.uploadUserData(user)
    }
    
    func updateRideState(rideId: String, toState state: RideState) async {
        try? await ServiceConstants.ridesCollection.document(rideId).updateData(["state": state.rawValue])
    }
}

// MARK: - Rider API
extension LocationService {
    func observeNearbyDrivers(for location: CLLocation?, completion: @escaping ([User]) -> Void) {
        observeNearbyDrivers(location: location, distance: 10) { completion($0) }
    }
    
    func confirmRide(pickupCoordinate: GeoPoint, destinationCoordinate: GeoPoint) -> Ride? {
        guard let passengerId = Auth.auth().currentUser?.uid else { return nil }
        
        let ride = Ride(
            passengerId: passengerId,
            pickupCoordinate: pickupCoordinate,
            destinationCoordinate: destinationCoordinate,
            timestamp: Timestamp(date: .now)
        )
        
        let _ = try? ServiceConstants.ridesCollection.addDocument(from: ride)
        
        return ride
    }
    
    func observeCurrentRideForRider(_ ride: Ride, completion: @escaping(Ride) -> Void) {
        guard let passengerId = Auth.auth().currentUser?.uid else { return }
        
        ServiceConstants.ridesCollection
            .whereField("timestamp", isEqualTo: ride.timestamp)
            .whereField("passengerId", isEqualTo: passengerId)
            .addSnapshotListener { snapshot, error in
                guard let ride = try? snapshot?.documents.first?.data(as: Ride.self) else { return }
                                
                completion(ride)
            }
    }
    
    func cancelRide(_ rideId: String?) async {
        guard let rideId else { return }
        
        try? await ServiceConstants.ridesCollection.document(rideId).delete()
    }
}

// MARK: - Driver API
extension LocationService {
    func acceptRide(_ ride: Ride?, completion: @escaping() -> Void) {
        guard var ride,
              let driverId = Auth.auth().currentUser?.uid,
              let rideId = ride.id else { return }
        
        ride.driverId = driverId
        ride.state = .accepted
        
        try? ServiceConstants.ridesCollection.document(rideId).setData(from: ride)
        
        completion()
    }
    
    func observeRides(completion: @escaping(Ride) -> Void) {
        ServiceConstants.ridesCollection
            .whereField("state", isEqualTo: 0) /// Looking for a requested state
            .addSnapshotListener { snapshot, error in
                guard let ride = try? snapshot?.documents.first?.data(as: Ride.self) else { return }
                
                completion(ride)
            }
    }
    
    func observeIfCurrentRideIsCancelled(_ rideId: String?, completion: @escaping() -> Void) {
        guard let rideId else { return }
        
        ServiceConstants.ridesCollection.document(rideId)
            .addSnapshotListener { snapshot, error in
                guard snapshot?.exists == false else { return}
                
                completion()
            }
    }
}

// MARK: - Private API
private extension LocationService {
    func observeNearbyDrivers(location: CLLocation?, distance: Double, completion: @escaping ([User]) -> Void) {
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
