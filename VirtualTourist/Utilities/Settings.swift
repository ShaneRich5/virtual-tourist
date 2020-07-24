//
//  Settings.swift
//  VirtualTourist
//
//  Created by Shane Richards on 7/22/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation
import MapKit

class Settings {
    private let defaults = UserDefaults.standard
    
    static let KEY_LATITUDE_DELTA = "latitude_delta"
    static let KEY_LONGITUDE_DELTA = "longitude_delta"
    static let KEY_LATITUDE_CENTRE = "latitude_centre"
    static let KEY_LONGITUDE_CENTRE = "longitude_centre"
    static let KEY_HAS_LAUNCHED_BEFORE = "has_launched_before"
    
    func hasLaunchedBefore() -> Bool {
        return defaults.bool(forKey: Settings.KEY_HAS_LAUNCHED_BEFORE)
    }
    
    func setHasLaunchedBefore(value: Bool) {
        defaults.set(value, forKey: Settings.KEY_HAS_LAUNCHED_BEFORE)
    }
    
    func getCentreCoordinate() -> CLLocationCoordinate2D {
        let latitude = defaults.double(forKey: Settings.KEY_LATITUDE_CENTRE)
        let longitude = defaults.double(forKey: Settings.KEY_LONGITUDE_CENTRE)
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func getSpanCoordinate() -> MKCoordinateSpan {
        let latitudeDelta = defaults.double(forKey: Settings.KEY_LATITUDE_DELTA)
        let longitudeDelta = defaults.double(forKey: Settings.KEY_LONGITUDE_DELTA)
        
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
    
    func setLatestMapRegion(centre: CLLocationCoordinate2D, span: MKCoordinateSpan) {
        defaults.set(centre.latitude, forKey: Settings.KEY_LATITUDE_CENTRE)
        defaults.set(centre.longitude, forKey: Settings.KEY_LONGITUDE_CENTRE)
        defaults.set(span.latitudeDelta, forKey: Settings.KEY_LATITUDE_DELTA)
        defaults.set(span.longitudeDelta, forKey: Settings.KEY_LONGITUDE_DELTA)
    }
}
