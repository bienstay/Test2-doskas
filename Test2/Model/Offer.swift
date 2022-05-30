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
        if let id = id,  let t = hotel.translations.offers[phoneUser.lang]?[id]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id,  let t = hotel.translations.offers[phoneUser.lang]?[id]?["subtitle"] { return t }
        else { return subTitle }
    }
    var _text: String {
        if let id = id,  let t = hotel.translations.offers[phoneUser.lang]?[id]?["text"] { return t }
        else { return text }
    }
}

struct OfferGroup: Codable {
    var id: String?

    var title: String = ""
    var subTitle: String = ""
    var offers: [String]?

    var _title: String {
        if let id = id,  let t = hotel.translations.offerGroups[phoneUser.lang]?[id]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id,  let t = hotel.translations.offerGroups[phoneUser.lang]?[id]?["subtitle"] { return t }
        else { return subTitle }
    }
}

