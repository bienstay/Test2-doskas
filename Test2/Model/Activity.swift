//
//  Activity.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import Foundation

struct Activity: Codable, Hashable {
    enum DOW : String, CaseIterable {
        case Monday = "Monday"
        case Tuesday = "Tuesday"
        case Wednesday = "Wednesday"
        case Thursday = "Thursday"
        case Friday = "Friday"
        case Saturday = "Saturday"
        case Sunday = "Sunday"
    }
    var id: String? = nil
    var title: String = ""
    var location: String? = ""
    var dayOfTheWeek: Int? = 0
    var start: Date = Date()
    var end: Date = Date()
    var imageFileURL: String = ""
    var text: String? = ""
}

struct DailyActivities: Codable {
    var activities:[Activity] = []
}

typealias DailyActivities2 = [String:Activity]
