//
//  Translations.swift
//  Test2
//
//  Created by maciulek on 27/10/2021.
//

import Foundation

struct Translations {
    // lang, id, key, value
    var news:           [String:[String:[String:String]]] = [:]
    var activities:     [String:[String:[String:String]]] = [:]
    var restaurants:    [String:[String:[String:String]]] = [:]
    var offerGroups:    [String:[String:[String:String]]] = [:]
    var offers:         [String:[String:[String:String]]] = [:]

    struct InfoItemTranslated: Codable {
        var title: String = ""
        var subtitle: String = ""
        var text: String = ""
        var imageTexts: [String] = []
    }
    var info: [String:[String:[String:Any]]] = [:]
}

