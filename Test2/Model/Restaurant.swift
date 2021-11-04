//
//  Restaurant.swift
//  Bibzzy
//
//  Created by maciulek on 27/04/2021.
//

import Foundation

class Restaurant: Place, Codable {
    var id: String?
    var name: String = ""
    var cuisines: String = ""
    var description: String = ""
    var image: String = ""
    var phone: String = ""
    var location: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0

    lazy var menus: [Menu2] = []

    init() {}
}

