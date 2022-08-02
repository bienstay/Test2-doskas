//
//  Restaurant.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import Foundation

struct RestaurantInDB: Codable {
    var id: String?
    var name: String
    var cuisines: String
    var description: String
    var image: String
    var phone: String?
    var location: String
    var geoLatitude: Double
    var geoLongitude: Double
    var menus: [String]?
    
    init(r: Restaurant) {
        id = r.id
        name = r.name
        cuisines = r.cuisines
        description = r.description
        image = r.image
        phone = r.phone
        location = r.location
        geoLatitude = r.geoLatitude
        geoLongitude = r.geoLongitude
        menus = r.menus
    }
}

class Restaurant: POI, Codable {
    var id: String = ""
    var name: String = ""
    var type: POIType { return .Restaurant }
    var cuisines: String = ""
    var description: String = ""
    var image: String = ""
    var phone: String = ""
    var location: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0
/*
    var _name: String {
        if let id = id,  let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["name"] { return t }
        else { return name }
    }
    var _cuisines: String {
        if let id = id,  let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["cuisines"] { return t }
        else { return cuisines }
    }
    var _location: String {
        if let id = id,  let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["location"] { return t }
        else { return location }
    }
    var _description: String {
        if let id = id,  let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["description"] { return t }
        else { return description }
    }
*/
    var _name: String {
        if let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["name"] { return t }
        else { return name }
    }
    var _cuisines: String {
        if let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["cuisines"] { return t }
        else { return cuisines }
    }
    var _location: String {
        if let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["location"] { return t }
        else { return location }
    }
    var _description: String {
        if let t = hotel.translations.restaurants[id]?[phoneUser.lang]?["description"] { return t }
        else { return description }
    }

    //lazy var menus: [Menu] = []
    var menus: [String] = []

    required init() {}

    convenience init(r: RestaurantInDB) {
        self.init()
        id = r.id ?? ""
        name = r.name
        cuisines = r.cuisines
        description = r.description
        image = r.image
        phone = r.phone ?? ""
        location = r.location
        geoLatitude = r.geoLatitude
        geoLongitude = r.geoLongitude
        menus = r.menus ?? []
    }
}

