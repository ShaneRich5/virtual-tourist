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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(mapTapped))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func mapTapped(sender: UIGestureRecognizer) {
        print("map tapped, \(sender.state)")
        
        if sender.state == .recognized {
            print("state recognized")
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            addAnnotation(location: locationOnMap)
        } else if sender.state == .began {
            print("state recognized")
        } else if sender.state == .changed {
           print("state changed")
       }
    }
    
    func addAnnotation(location: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = location
        annotation.title = "Some Title"
        annotation.subtitle = "Some Subtitle"
        self.mapView.addAnnotation(annotation)
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    
}
