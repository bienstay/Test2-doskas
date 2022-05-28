//
//  Activity.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import Foundation

struct Activity: Codable, Hashable {
    enum DOW : String, CaseIterable {
        case Sunday = "Sunday"
        case Monday = "Monday"
        case Tuesday = "Tuesday"
        case Wednesday = "Wednesday"
        case Thursday = "Thursday"
        case Friday = "Friday"
        case Saturday = "Saturday"
    }
    static func DOWIndex(_ s: String) -> Int? {
        switch s {
        case "Sunday": return 0
        case "Monday": return 1
        case "Tuesday": return 2
        case "Wednesday": return 3
        case "Thursday": return 4
        case "Friday": return 5
        case "Saturday": return 6
        default: return nil
        }
    }
    var id: String? = nil
    var title: String = ""
    var subtitle: String? = ""
    var dayOfTheWeek: Int? = 0
    var start: Date = Date()
    var end: Date = Date()
    var imageFileURL: String = ""
    var text: String? = ""
    var _title: String {
        if let id = id,  let t = hotel.translations.activities[phoneUser.lang]?[id]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id,  let t = hotel.translations.activities[phoneUser.lang]?[id]?["subtitle"] { return t }
        else { return subtitle ?? "" }
    }
    var _text: String {
        if let id = id,  let t = hotel.translations.activities[phoneUser.lang]?[id]?["text"] { return t }
        else { return text ?? "" }
    }
}

typealias DailyActivities = [String:Activity]
