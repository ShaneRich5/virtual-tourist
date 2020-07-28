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

class PhotoAlbumViewController: UIViewController, UICollectionViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var location: Location!
    var dataController: DataController!
    var fetchResultsController: NSFetchedResultsController<Photo>!
    
    var isLoadingImages: Bool {
        get {
            if let photos = fetchResultsController?.fetchedObjects {
                for photo in photos {
                    if (photo.isLoading) {
                        return true
                    }
                }
            }
            
            return false
        }
    }
    
    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: false)
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let photo = fetchResultsController.object(at: indexPath)
        dataController.viewContext.delete(photo)
        try? dataController.viewContext.save()
    }
    
    func fetchPhotos() {
        showLoadingState(to: true)
        
        FlickrClient.searchPhotosByLocation(latitude: location.latitude, longitude: location.longitude, completion: { photoMetas, error in
            guard let photoMetas = photoMetas, error == nil else {
                print("Failed to load photos! \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            for photoMeta in photoMetas {
                let photo = Photo(context: self.dataController.viewContext)
                photo.creationDate = Date()
                photo.url = photoMeta.toUrl()
                photo.location = self.location
                photo.isLoading = true
                try? self.dataController.viewContext.save()
                
                self.downloadImageForPhoto(photo: photo)
            }
            
            self.collectionView.reloadData()
        })
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
        
        let space: CGFloat = 3.0
        let width = (view.frame.size.width - (2 * space)) / 3.0
        let height = (view.frame.size.height - (2 * space)) / 3.0
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: width, height: height)
        
        if (fetchResultsController.fetchedObjects?.count == 0) {
            fetchPhotos()
        } else {
            showLoadingState(to: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchResultsController = nil
    }
    
    func showLoadingState(to isLoading: Bool) {
        if isLoading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
        
        newCollectionButton.isEnabled = !isLoading
    }
    
    @IBAction func newCollectionPressed(_ sender: Any) {
        guard let photos = fetchResultsController.fetchedObjects  else {
            return
        }
        
        for photo in photos {
            dataController.viewContext.delete(photo)
            try? dataController.viewContext.save()
        }
        
        fetchPhotos()
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
            break
        case .update:
            collectionView.reloadItems(at: [indexPath!])
            break
        default:
            break
        }
    }
}

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResultsController?.fetchedObjects?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        let photo = fetchResultsController.object(at: indexPath)
        
        if let data = photo.data {
            cell.imageView.image = UIImage(data: data)
        } else {
            cell.imageView.image = UIImage(named: "VirtualTourist")
        }
        cell.imageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func downloadImageForPhoto(photo: Photo) {
        FlickrClient.downloadImage(url: photo.toURL(), completion: { data, error in
            photo.isLoading = false
            
            if (!self.isLoadingImages) {
                self.showLoadingState(to: false)
            }
            
            guard let data = data, error == nil else {
                print("DownloadImage failed: error fetching image! \(error?.localizedDescription ?? "unknown error")")
                return
            }
            
            photo.data = data
            try? self.dataController.viewContext.save()
        })
    }
}
