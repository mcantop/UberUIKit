//
//  MKPlacemark+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 31/08/2023.
//

import MapKit

extension MKPlacemark {
    var address: String {
        get {
            guard let subThoroughfare,
                  let thoroughfare,
                  let locality,
                  let administrativeArea else { return "Couldn't get address."}
            
            return "\(subThoroughfare) \(thoroughfare), \(locality), \(administrativeArea)"
        }
    }
}
