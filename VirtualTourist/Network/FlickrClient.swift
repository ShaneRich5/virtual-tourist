//
//  FlickrClient.swift
//  VirtualTourist
//
//  Created by Shane Richards on 5/16/20.
//  Copyright © 2020 Shane Richards. All rights reserved.
//

import Foundation


class FlickrClient {
    struct Constants {
        static let BASE_URL = "https://api.flickr.com/services/rest"
        static let API_KEY = "2e506c3b21b8b7225d64e74f2e372a7a"
        static let API_METHOD = "flickr.photos.search"
        static let API_SECRET = "ec9db3287f620f60"
    }
    
    enum Endpoints {
        case photo(Int, Int, Int, String)
        case search(Double, Double)
        case base
        
        var stringValue: String {
            switch self{
            case .base:
                return "\(Constants.BASE_URL)?api_key=\(Constants.API_KEY)&method=\(Constants.API_METHOD)"
            case .photo(let farmId, let serverId, let photoId, let photoSecret):
                return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(photoSecret).jpg"
            case .search(let latitude, let longitude):
                return "\(Endpoints.base.stringValue)&per_page=20&format=json&nojsoncallback=?&lat=\(latitude)&lon=\(longitude)&page=1"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    @discardableResult class func taskForGetRequest<ResponseType: Decodable>(
        url: URL,
        responseType: ResponseType.Type,
        completion: @escaping (ResponseType?, Error?) -> Void
    ) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let object = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(object, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        
        task.resume()
        return task
    }
    
    @discardableResult class func downloadImage(url: URL, completion: @escaping (Data?, Error?) -> Void) -> URLSessionTask {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                DispatchQueue.main.async { completion(nil, error) }
                return
            }
            
            DispatchQueue.main.async { completion(data, nil) }
        }
        
        task.resume()
        return task
    }
    
    @discardableResult class func searchPhotosByLocation(latitude: Double, longitude: Double, completion: @escaping ([PhotoMeta]?, Error?) -> Void) -> URLSessionTask {
        let url = Endpoints.search(latitude, longitude).url
        
        return taskForGetRequest(url: url, responseType: FlickrResponse.self, completion: { response, error in
            
            if let photos = response?.photos.photo {
                completion(photos, nil)
            } else {
                completion(nil, error)
            }

        })
    }
}
