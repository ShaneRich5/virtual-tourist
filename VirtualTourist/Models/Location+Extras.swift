//
//  Location+Extras.swift
//  VirtualTourist
//
//  Created by Shane Richards on 7/22/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation
import MapKit

extension Location {
    static func fromCoordinate(coordinate: CLLocationCoordinate2D) -> Location {
        let location = Location()
        location.latitude = coordinate.latitude
        location.longitude = coordinate.longitude
        return location
    }
    
    func toAnnotation() -> MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}
