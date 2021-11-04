//
//  Menu.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation

/*
struct MenuItem: Hashable, Codable {
    typealias ItemType = String
    static let GROUP:ItemType = "GROUP"
    static let FOODITEM:ItemType = "FOOD"

    var itemType: ItemType = GROUP
    var title: String = ""
    var description: String = ""

    // only for a FOODITEM
    var type: String = ""
    var price: Double = 0
    var attributes: [String]? = []
    var imageName: String = ""
}

struct MenuSection: Hashable, Codable {
    var title: String = ""
    var description: String = ""
    var items: [MenuItem] = []
}

struct Menu: Hashable, Codable {
    var restaurant: String = ""
    var position: Int = 0
    var title: String = ""
    var description: String = ""
    var sections: [MenuSection]? = []
}
*/

struct MenuItem2: Hashable, Codable {
    typealias ItemType = String
    static let GROUP:ItemType = "GROUP"
    static let FOODITEM:ItemType = "FOOD"
    static let SECTION:ItemType = "SECTION"

    var type: ItemType = GROUP
    var title: String = ""
    var txt: String = ""

    // only for a FOODITEM
    var price: Double = 0
    var attributes: [String]? = []
    var img: String = ""
}

struct Menu2: Hashable, Codable {
    var restaurant: String = ""
    var position: Int = 0
    var title: String = ""
    var txt: String = ""
    var items: [MenuItem2]? = []
}
/*
img = "";
itemType = FOOD;
note = "";
price = 18;
rating = 0;
title = "ALANAASI COLADA";
txt = "Aged rum, pineapple juice & colada mix";
*/
