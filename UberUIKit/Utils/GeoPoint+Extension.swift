//
//  GeoPoint+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 03/09/2023.
//

import Firebase
import MapKit

extension GeoPoint {
    var asCoordinate2D: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
