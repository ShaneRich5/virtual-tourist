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
    
    let settings = Settings()
    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Location>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        loadSavedAnnotations()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "OK", style: .plain, target: nil, action: nil)
    }
    
    func configureMap() {
        if settings.hasLaunchedBefore() {
            let centre = settings.getCentreCoordinate()
            let span = settings.getSpanCoordinate()
            let region = MKCoordinateRegion(center: centre, span: span)
            mapView.setRegion(region, animated: true)
        } else {
            settings.setHasLaunchedBefore(value: true)
            settings.setLatestMapRegion(centre: mapView.region.center, span: mapView.region.span)
        }
        
        let tapGesture = UILongPressGestureRecognizer(target: self, action: #selector(mapLongPressed))
        
        mapView.delegate = self
        mapView.addGestureRecognizer(tapGesture)
    }
    
    func loadSavedAnnotations() {
        do {
            let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
            let locations = try dataController.viewContext.fetch(fetchRequest)
            let annotations = locations.map { location in location.toAnnotation() }
                
            mapView.addAnnotations(annotations)
        } catch {
            print("Failed to load locations: \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController!.setNavigationBarHidden(true, animated: false)
        setupFetchedResultsController()
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "locations")
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch photos for \(error.localizedDescription)")
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController!.setNavigationBarHidden(false, animated: false)
        fetchedResultsController = nil
    }
    
    @objc func mapLongPressed(sender: UIGestureRecognizer) {
        guard sender.state == .began else {
            // only interested in long presses
            return
        }
        
        let locationInView = sender.location(in: mapView)
        let coordinate = mapView.convert(locationInView, toCoordinateFrom: mapView)
        
        do {
            let location = Location(context: dataController.viewContext)
            location.latitude = coordinate.latitude
            location.longitude = coordinate.longitude
            location.creationDate = Date()
            try dataController.viewContext.save()
        } catch {
            print("Failed to save location: \(error.localizedDescription)")
        }
    }
}

extension TravelLocationViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            let annotation = (anObject as! Location).toAnnotation()
            mapView.addAnnotation(annotation)
            break
        default:
            break
        }
    }
}

extension TravelLocationViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        settings.setLatestMapRegion(centre: mapView.region.center, span: mapView.region.span)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumController = self.storyboard?.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        
        mapView.deselectAnnotation(view.annotation, animated: false)

        guard let coordinate = view.annotation?.coordinate else {
            print("Failed to access coordinate...")
            return
        }
        
        let fetchRequest: NSFetchRequest<Location> = Location.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %d and longitude == %d", argumentArray: [coordinate.latitude, coordinate.longitude])
        fetchRequest.predicate = predicate
        
        do {
            let location = try dataController.viewContext.fetch(fetchRequest).first
            
            photoAlbumController.location = location
            photoAlbumController.dataController = dataController
            
            navigationController!.pushViewController(photoAlbumController, animated: true)
        } catch {
            print("Failed to configure the photo album view controller")
        }
    }
}
