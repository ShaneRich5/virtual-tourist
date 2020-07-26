//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/4/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var location: Location!
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<Photo>!
    
    var urls = [String]()
    
    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: false)
        
        collectionView.dataSource = self
        
        
        showLoadingState(true)
        
        
        
        FlickrClient.searchPhotosByLocation(latitude: location.latitude, longitude: location.longitude, completion: handleFlickPhotoListResponse(photoDetails:error:))
    }
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest: NSFetchRequest<Photo> = Photo.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "location == %@", location)
        
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(location.latitude)-\(location.longitude)")
        
        fetchResultsController.delegate = self
        
        do {
            try fetchResultsController.performFetch()
        } catch {
            fatalError("Failed to fetch photos for \(error.localizedDescription)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    
    func handleFlickPhotoListResponse(photoDetails: [PhotoMeta]?, error: Error?) {
        guard let photoDetails = photoDetails, error == nil else {
            print("Failed to load photos! \(error?.localizedDescription ?? "unknown error")")
            return
        }
        
        print("photoDetails: \(photoDetails)")
    
        showLoadingState(false)
        urls = photoDetails.map { $0.toUrl() }
        collectionView.reloadData()
    }
    
    func showLoadingState(_ isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        newCollectionButton.isEnabled = !isLoading
    }
}

extension PhotoAlbumViewController: NSFetchedResultsControllerDelegate {
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        default:
            break
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchResultsController.object(at: indexPath)
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let index = (indexPath as NSIndexPath).row
        
        
        let urlString = self.urls[index]
        
        guard let url = URL(string: urlString) else {
            print("collectionView: image broken")
            return cell
        }
        
        FlickrClient.downloadImage(url: url, completion: { data, error in
            print(urlString)
            guard let data = data, error == nil else {
                print("DownloadImage: error fetching image! \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            let image = UIImage(data: data)
            cell.imageView.image = image
        })
        
        return cell
    }
}
