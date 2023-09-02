//
//  MKMapView+Extension.swift
//  UberUIKit
//
//  Created by Maciej on 02/09/2023.
//

import MapKit

extension MKMapView {
    func zoomToFit(annotation: [MKAnnotation], rideActionViewHeight: CGFloat) {
        var zoomRect = MKMapRect.null
        
        annotation.forEach { annotation in
            let annotationPoint = MKMapPoint(annotation.coordinate)
            let pointRect = MKMapRect(x: annotationPoint.x, y: annotationPoint.y, width: 0.01, height: 0.01)
            
            zoomRect = zoomRect.union(pointRect)
        }
        
        let padding = UIEdgeInsets(top: 75, left: 100, bottom: rideActionViewHeight, right: 100)
        
        setVisibleMapRect(zoomRect, edgePadding: padding, animated: true)
    }
}
