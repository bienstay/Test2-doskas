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
}

struct OfferGroup: Codable {
    var id: String?

    var title: String = ""
    var subTitle: String = ""
    var offers: [String]?
}

