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
    static let photoAlbumSegue = "photoAlbum"
    static let reusePinIdentifier = "albumPin"
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations: [Location] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "OK", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.setNavigationBarHidden(false, animated: false)
    }
    
    func configureMap() {
        mapView.delegate = self
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    @objc func mapLongPressed(sender: UIGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            
            let location = Location.fromCoordinate(coordinate: coordinate)
            locations.append(location)
        }
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
                
        photoAlbumController.annotation = view.annotation
        navigationController!.pushViewController(photoAlbumController, animated: true)
    }
}
