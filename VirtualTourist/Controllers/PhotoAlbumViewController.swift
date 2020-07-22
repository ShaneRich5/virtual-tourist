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
    var annotation: MKAnnotation!
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var newCollectionButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var urls = [String]()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLoadingState(true)
        
        let longitude = self.annotation.coordinate.longitude
        let latitude = self.annotation.coordinate.latitude
        
        FlickrClient.searchPhotosByLocation(latitude: latitude, longitude: longitude, completion: handleFlickPhotoListResponse(photoDetails:error:))
        
        print(self.annotation.coordinate)
    }
    
    func handleFlickPhotoListResponse(photoDetails: [PhotoMeta]?, error: Error?) {
        guard let photoDetails = photoDetails, error == nil else {
            print("Failed to load photos! \(error)")
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
                print("downloadImage: error fetching image! \(error)")
                return
            }
            
            let image = UIImage(data: data)
            cell.imageView.image = image
        })
        
        return cell
    }
}
