//
//  Photo+Extras.swift
//  VirtualTourist
//
//  Created by Shane Richards on 7/26/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation

extension Photo {
    func toURL() -> URL {
        return URL(string: url!)!
    }
}
