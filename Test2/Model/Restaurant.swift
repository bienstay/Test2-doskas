//
//  Restaurant.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import Foundation
/*
class Restaurant: Place, Codable {
    var imageURL: String
    var name: String = ""
    var description: String = ""
    var image: Data = Data()
    var icon: Data = Data()
    var phone: String = ""
    var location: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0

    var cuisines: [String] = []
    var menus: [Menu] = []
    
    init() {}
}
*/

class Restaurant: Place, Codable {
    var name: String = ""
    var description: String = ""
    var image: String = ""
    var phone: String = ""
    var location: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0

    var cuisines: [String] = []
    lazy var menus: [Menu] = []

    init() {}
}


/*
func loadRestaurants(fromServerURL: String, completionClosure: @escaping ()->()) {
    
    let remoteURL = URL(string: fromServerURL)!
    var req = URLRequest(url: remoteURL)
    req.cachePolicy = .useProtocolCachePolicy

    let downloadTask = URLSession.shared.downloadTask(with: req) { localURL, urlResponse, error in
        guard let localURL = localURL else { print("localURL == nil"); return }
        guard let urlResponse = urlResponse else { print("urlResponse == nil"); return }

        // decode the response and put it in the hotel data
        if let jsonString = try? String(contentsOf: localURL) {
            let restaurants = try! JSONDecoder().decode([Restaurant].self, from: jsonString.data(using: .utf8)!)
            hotel.facilities[.Restaurant] = Dictionary(uniqueKeysWithValues: restaurants.map{ ($0.name, $0) })
            print("Loaded \(restaurants.count) restaurants")
            completionClosure()
        }

        // put the response in the cache
        if (URLCache.shared.cachedResponse(for: req) == nil) {
            print("Restaurants - writing to the cache")
            if let data = try? Data(contentsOf: localURL) {
                URLCache.shared.storeCachedResponse(CachedURLResponse(response: urlResponse, data: data), for: req)
            }
        }
        else { print("Restaurants - already in the cache") }
    }
    downloadTask.resume()
}


func loadRestaurantsImagesFromBundle() {
    for r in hotel.facilities[.Restaurant] as! [String: Restaurant] {
        if let bundlePath = Bundle.main.path(forResource: r.key, ofType: "jpg") {
            do {
                try r.value.image = Data(contentsOf: URL(fileURLWithPath: bundlePath))
            }
            catch {
                print(error)
            }
        }
    }
}
*/
