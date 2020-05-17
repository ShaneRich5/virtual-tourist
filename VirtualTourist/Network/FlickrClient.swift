//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/16/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation


class FlickrClient {
    struct Api {
        let scheme = "https"
        let host = "api.flickr.com"
        let path = "/services/rest"
        
        func buildUrl() -> URL {
            let url = "\(scheme)://\(host)\(path)"
            return URL(string: url)!
        }
    }
}
