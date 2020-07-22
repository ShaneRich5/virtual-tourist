//
//  FlickrResponse.swift
//  VirtualTourist
//
//  Created by Shane Richards on 7/6/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation

class FlickrResponse: Codable {
    var photos: FlickMeta
    var stat: String
}

class FlickMeta: Codable {
    var page: Int
    var pages: Int
    var perpage: Int
    var total: String
    var photo: [PhotoMeta]
}

class PhotoMeta: Codable {
    var id: String
    var owner: String
    var secret: String
    var server: String
    var farm: Int
    var title: String
    var ispublic: Int
    var isfriend: Int
    var isfamily: Int
    
    func toUrl() -> String {
        return "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
}
