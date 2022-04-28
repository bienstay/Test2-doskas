//
//  BarcodeData.swift
//  Test2
//
//  Created by maciulek on 31/03/2022.
//

import Foundation

struct BarcodeData: Codable {
    var hotelId: String

    var roomNumber: Int?
    var startDate: Date?
    var endDate: Date?
    var guestName: String?

    var userName: String?
    var password: String?

    func isValid() -> Bool { return
        !hotelId.isEmpty && (
            roomNumber ?? 0 > 0 && startDate != nil ||
            !(userName ?? "").isEmpty && !(password ?? "").isEmpty
        )
    }
}
