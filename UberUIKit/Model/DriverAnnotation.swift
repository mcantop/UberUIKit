//
//  DriverAnnotation.swift
//  UberUIKit
//
//  Created by Maciej on 30/08/2023.
//

import MapKit

private enum Constants {
    static let updateAnnotationAnimationDuration = 2.0
}

final class DriverAnnotation: NSObject, MKAnnotation, Reusable {
    // MARK: - Properties
    let uid: String
    dynamic var coordinate: CLLocationCoordinate2D /// Dynamic required
    
    // MARK: - Init
    init(uid: String, coordinate: CLLocationCoordinate2D) {
        self.uid = uid
        self.coordinate = coordinate
    }
    
    // MARK: - Public API
    func updateAnnotation(withNewCoordinate coordinate: CLLocationCoordinate2D) {
        UIView.animate(withDuration: Constants.updateAnnotationAnimationDuration) {
            self.coordinate = coordinate
        }
    }
}
