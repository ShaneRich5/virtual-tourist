//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/4/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var location: Location!
    var dataController: DataController!
    
    var urls = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.dataSource = self
    }
    
    override func viewDidLoad() {
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        mapView.addAnnotation(annotation)
        mapView.setCenter(coordinate, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingState(true)
        
        FlickrClient.searchPhotosByLocation(latitude: location.latitude, longitude: location.longitude, completion: handleFlickPhotoListResponse(photoDetails:error:))
    }
    
    func handleFlickPhotoListResponse(photoDetails: [PhotoMeta]?, error: Error?) {
        guard let photoDetails = photoDetails, error == nil else {
            print("Failed to load photos! \(error?.localizedDescription)")
            return
        }
    
        showLoadingState(false)
        urls = photoDetails.map { $0.toUrl() }
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        showLoadingState(false)
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

extension PhotoAlbumViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.urls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        
        let urlString = self.urls[(indexPath as NSIndexPath).row]
        
        guard let url = URL(string: urlString) else {
            print("collectionView: image broken")
            return cell
        }
        
        FlickrClient.downloadImage(url: url, completion: { data, error in
            print(urlString)
            guard let data = data, error == nil else {
                print("DownloadImage: error fetching image! \(error?.localizedDescription)")
                return
            }
            
            let image = UIImage(data: data)
            cell.imageView.image = image
        })
        
        return cell
    }
}
