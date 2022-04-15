//
//  BarcodeData.swift
//  Test2
//
//  Created by maciulek on 31/03/2022.
//

import Foundation

struct BarcodeData: Codable {
    var roomNumber: Int
    var hotelId: String

    var startDate: Date?
    var endDate: Date?
    var guestName: String?

    var userName: String?
    var password: String?

    func isValid() -> Bool { return roomNumber > 0 && !hotelId.isEmpty }
}
