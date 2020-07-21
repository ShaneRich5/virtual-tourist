//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Shane Richards on 7/7/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    public static var reuseIdentifier = "PhotoCollectionViewCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    func configure (url: String) {
        imageView.image = UIImage()
    }
}
