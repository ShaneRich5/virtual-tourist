//
//  TravelLocationViewController.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/3/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationViewController: UIViewController {
    static let photoAlbumSegue = "photoAlbum"
    static let reusePinIdentifier = "albumPin"
    
    @IBOutlet weak var mapView: MKMapView!
    
    var locations: [Location] = []
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        loadSavedAnnotations()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "OK", style: .plain, target: nil, action: nil)
    }
    
    func configureMap() {
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed))
        
        mapView.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func loadSavedAnnotations() {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        if let result = try? dataController.viewContext.fetch(fetchRequest) {
            locations = result
        }
        
        let annotations = locations.map { location in location.toAnnotation() }
        mapView.addAnnotations(annotations)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.setNavigationBarHidden(false, animated: false)
    }
    
    @objc func mapLongPressed(sender: UIGestureRecognizer) {
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            mapView.addAnnotation(annotation)
            
            let location = Location(context: dataController.viewContext)
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            location.creationDate = Date()
            try? dataController.viewContext.save()
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
