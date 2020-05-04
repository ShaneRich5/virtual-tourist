//
//  TravelLocationViewController.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/3/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import UIKit
import MapKit

class TravelLocationViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
    }
    
    func configureMap() {
        mapView.delegate = self
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func mapLongPressed(sender: UIGestureRecognizer) {
        print("map tapped, \(sender.state)")
        
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationOnMap
            self.mapView.addAnnotation(annotation)
        }
    }

}

extension TravelLocationViewController: MKMapViewDelegate {
    
}
