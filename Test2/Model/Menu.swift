//
//  Menu.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation


struct MenuItemInDB: Hashable, Codable {
    var type: MenuItem.ItemType
    var title: String
    var txt: String
    var price: String?
    //var attributes: String?
    //var choices: [String:Double]? = [:]
    var choices: [[String:Double]]? = []
    var addons: [String:Double]? = [:]
    var img: String?
    init (_ m: MenuItem) {
        type = m.type
        title = m.title
        txt = m.text
        price = String(m.price)
        //attributes = m.attributes.joined(separator: " ")
        choices = m.choices?.map { [$0.title:$0.price] }
        m.addons?.forEach { addons?[$0.title] = $0.price }
        img = m.img
    }
}

extension MenuItem {
    init(_ m: MenuItemInDB) {
        type = m.type
        title = m.title
        text = m.txt
        price = Double(m.price ?? "0.0") ?? 0.0
        //attributes = m.attributes?.components(separatedBy: [",", ".", " "]).filter({!$0.isEmpty}) ?? []
        foodAttributes = []
        //choices = m.choices?.sorted(by: {$0.key < $1.key}).map { Subchoice(title: $0.key, price: $0.value) }
        choices = m.choices?.map { Subchoice(title: $0.first?.key ?? "", price: $0.first?.value ?? 0.0) }
        addons = m.addons?.sorted(by: {$0.key < $1.key}).map { Subchoice(title: $0.key, price: $0.value) }
        img = m.img
    }
}

func == <T1:Equatable, T2:Equatable> (tuple1:(T1,T2),tuple2:(T1,T2)) -> Bool
{
   return (tuple1.0 == tuple2.0) && (tuple1.1 == tuple2.1)
}

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
    var type: ItemType = .GROUP
    var title: String = ""
    var text: String = ""
    var price: Double = 0.0
    var foodAttributes: [String] = []
    var choices: [Subchoice]? = []
    var addons: [Subchoice]? = []
    var img: String? = ""
}



struct MenuInDB: Hashable, Codable {
    var name: String = ""
    var txt: String? = ""
    var items: [MenuItemInDB]? = []
    init(_ m: Menu) {
        name = m.name
        txt = m.text
        m.items.forEach( { items?.append(MenuItemInDB($0)) } )
    }
}

extension Menu {
    init(_ m: MenuInDB) {
        name = m.name
        text = m.txt
        m.items?.forEach( { items.append(MenuItem($0)) } )
    }
}

struct Menu: Hashable, Codable {
    var name: String = ""
    var text: String? = ""
    var items: [MenuItem] = []
}
