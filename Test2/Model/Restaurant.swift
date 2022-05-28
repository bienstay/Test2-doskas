//
//  Restaurant.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import Foundation

class Restaurant: POI, Codable {
    var id: String?
    var name: String = ""
    var type: POIType { return .Restaurant }
    var cuisines: String = ""
    var description: String = ""
    var image: String = ""
    var phone: String = ""
    var location: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0

    var _name: String {
        if let id = id,  let t = hotel.translations.restaurants[phoneUser.lang]?[id]?["name"] { return t }
        else { return name }
    }
    var _cuisines: String {
        if let id = id,  let t = hotel.translations.restaurants[phoneUser.lang]?[id]?["cuisines"] { return t }
        else { return cuisines }
    }
    var _location: String {
        if let id = id,  let t = hotel.translations.restaurants[phoneUser.lang]?[id]?["location"] { return t }
        else { return location }
    }
    var _description: String {
        if let id = id,  let t = hotel.translations.restaurants[phoneUser.lang]?[id]?["description"] { return t }
        else { return description }
    }

    lazy var menus: [Menu2] = []

    required init() {}
}

