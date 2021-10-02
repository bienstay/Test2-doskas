//
//  HotelTestData.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation
import UIKit

func initInfoItems() {
    var infoItem = InfoItem()
    infoItem.itemId = "1"
    infoItem.title = "Adopt a Coral"
    infoItem.subtitle = "Coral reef restoration program"
    infoItem.text = "The “Adopt a Coral” program at Sheraton Maldives Full Moon Resort & Spa began in 2020. Teamed up with Reefscapers, the resort invites guests to participate in the coral-fragment plantation activity in an effort to promote reef habitats and guest will receive with bi-annual picture updates."
    infoItem.timestamp = Date()

    infoItem.images.append((url: "adoptacoral1.jpg", text: "Guided House Reef Snorkeling Tour\nJoin our marine biologist on a private snorkeling tour of our house reef to learn about our coral propagation program and the marine life it cultivated."))
    infoItem.images.append((url: "adoptacoral2.jpg", text: "Little Marine Biologist For A Day\nThis fun and interactive learning experience allows kids to embark on a journey with our marine biologist and accompany on her mission to save corals and build reefs."))
    infoItem.images.append((url: "adoptacoral3.jpg", text: "Marine life talk\nJoin us on an engaging conversation about marine conservation with our marine biologist Amélie Carraut"))
 
//    infoItem.images.append((url: "OnboardingInfo", text: ""))
//    infoItem.images.append((url: "OnboardingOrders", text: ""))
//    infoItem.images.append((url: "OnboardingRestaurant", text: ""))
    hotel.infoItems.append(infoItem)
}
