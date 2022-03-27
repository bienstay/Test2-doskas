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

    lazy var menus: [Menu2] = []

    required init() {}
}

