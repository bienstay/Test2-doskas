//
//  Offer.swift
//  Test2
//
//  Created by maciulek on 20/11/2021.
//

import Foundation


struct Offer: Codable {
    var id: String?

    var title: String = ""
    var subTitle: String = ""
    var imageURL: String = ""
    var price: String = ""
    var text: String = ""

    var _title: String {
        if let id = id,  let t = hotel.translations.offers[id]?[phoneUser.lang]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id,  let t = hotel.translations.offers[id]?[phoneUser.lang]?["subtitle"] { return t }
        else { return subTitle }
    }
    var _text: String {
        if let id = id,  let t = hotel.translations.offers[id]?[phoneUser.lang]?["text"] { return t }
        else { return text }
    }
}

struct OfferGroup: Codable {
    var id: String?

    var title: String = ""
    var subTitle: String = ""
    var offers: [String]?

    var _title: String {
        if let id = id,  let t = hotel.translations.offerGroups[id]?[phoneUser.lang]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id,  let t = hotel.translations.offerGroups[id]?[phoneUser.lang]?["subtitle"] { return t }
        else { return subTitle }
    }
}

