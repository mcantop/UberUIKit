//
//  Ride.swift
//  UberUIKit
//
//  Created by Maciej on 02/09/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

enum RideState: Int, Codable {
    case requested
    case accepted
    case inProgress
    case completed
}

struct Ride: Codable {
    @DocumentID var id: String?
    
    let passengerId: String
    let pickupCoordinate: GeoPoint
    let destinationCoordinate: GeoPoint
    
    var state: RideState = .requested
    var driverId: String? = nil
}
