//
//  Menu.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation


struct MenuItem: Hashable, Codable {
    enum ItemType: String, Codable {
        case GROUP = "GROUP"
        case FOODITEM = "FOOD"
        case SECTION = "SECTION"
    }
    struct Subchoice: Hashable, Codable {
        var title: String
        var price: Double
    }
    var id: String = ""
    var type: ItemType = .GROUP
    var title: String = ""
    var text: String = ""
    var price: Double = 0.0
    var foodAttributes: [String] = []
    var choices: [Subchoice]? = []
    var addons: [Subchoice]? = []
    var img: String? = ""
}

struct Menu: Hashable, Codable {
    var name: String = ""
    var text: String? = ""
    var items: [MenuItem] = []
}


struct MenuItemInDB: Hashable, Codable {
    var id: String?
    var type: MenuItem.ItemType
    var title: String
    var txt: String
    var price: String?
    var attributes: String?
    var choices: [[String:Double]]? = []
    var addons: [String:Double]? = [:]
    var img: String?
    init (_ m: MenuItem) {
        id = m.id
        type = m.type
        title = m.title
        txt = m.text
        price = String(m.price)
        attributes = m.foodAttributes.joined(separator: " ")
        choices = m.choices?.map { [$0.title:$0.price] }
        m.addons?.forEach { addons?[$0.title] = $0.price }
        img = m.img
    }
}

extension MenuItem {
    init(key: String, dbItem m: MenuItemInDB) {
        id = key
        type = m.type
        title = m.title
        text = m.txt
        price = Double(m.price ?? "0.0") ?? 0.0
        foodAttributes = m.attributes?.components(separatedBy: ",; ") ?? []
        choices = m.choices?.map { Subchoice(title: $0.first?.key ?? "", price: $0.first?.value ?? 0.0) }
        addons = m.addons?.sorted(by: {$0.key < $1.key}).map { Subchoice(title: $0.key, price: $0.value) }
        img = m.img
    }
}

struct MenuInDB: Hashable, Codable {
    var name: String = ""
    var txt: String? = ""
    var items: [String:MenuItemInDB]? = [:]
    init(_ m: Menu) {
        name = m.name
        txt = m.text
        m.items.forEach( { items?[$0.id] = MenuItemInDB($0) } )
    }
}

extension Menu {
    init(_ m: MenuInDB) {
        name = m.name
        text = m.txt
        items = m.items?.sorted(by: { $0.key < $1.key }).map { MenuItem(key:$0.0, dbItem: $0.1) } ?? []
    }
}

