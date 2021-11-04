//
//  Hotel.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import UIKit

protocol Place {
    var name: String { get }
    var description: String { get }
    var image: String { get }
    var location: String { get }
    var geoLatitude: Double { get }
    var geoLongitude: Double { get }
}

enum FacilityType {
    case Restaurant
    case Spa
    case Fitness
    case Watersports
    case Divecenter
}

struct DestinationDiningItem {
    var title: String = ""
    var timeLocation: String = ""
    var description: String = ""
    var price: String = ""
    var image: String = ""   // TODO - should be changed to Data or not ?
}

struct DestinationDiningGroup {
    var title: String
    var description: String
    var image: String   // TODO - should be changed to Data or not ?
    var items: [DestinationDiningItem] = []
}

struct DestinationDining {
    var headline = ("", "", "")
    var groups: [DestinationDiningGroup] = []
}

struct NewsPost: Codable {
    var postId: String = ""
    var timestamp: Date = Date()
    var imageFileURL: String = ""
    var title: String = ""
    var subtitle: String = ""
    var text: String = ""
    mutating func setText(s: String) { text = s }
}

struct InfoItem {
    var itemId: String = ""
    var timestamp: Date = Date()
    var images: [(url: String, text: String)] = []
    var title: String = ""
    var subtitle: String = ""
    var text: String = ""
}

struct HotelIInfo: Codable {
    var name: String
    var image: String
}

class Hotel {
    var id: String = "SheratonFullMoon" // default hotel
    var name: String = ""
    var image: String = ""
    var restaurants: [Restaurant] = []
    var roomService: Restaurant = Restaurant()
    var destinationDining: DestinationDining = DestinationDining()
    var news: [NewsPost] = []
    var infoItems: [InfoItem] = []
    var importantNotes: [InfoItem] = []
    var roomItems: [RoomItem.ItemType : [RoomItem]] = [:]
    var activities: [String: [Activity]] = [:]
    var translations: [String: Translations] = [:]

    func initialize() {
        roomItems = loadFromJSON(fileNameNoExt: "roomItems")
    }

    func startObserving() {
        FireB.shared.subscribeForUpdates(completionHandler: hotelInfoUpdated)
        FireB.shared.subscribeForUpdates(completionHandler: restaurantsUpdated)
        FireB.shared.subscribeForUpdates(completionHandler: newsUpdated)
        FireB.shared.subscribeForUpdates(completionHandler: activitiesUpdated)
        FireB.shared.subscribeForUpdates(completionHandler: translationsUpdated)
    }

    func hotelInfoUpdated(allHotelInfo: [(String, HotelIInfo)]) {
        hotel.name = allHotelInfo.first?.1.name ?? "HOTEL"
        hotel.image = allHotelInfo.first?.1.image ?? ""
        NotificationCenter.default.post(name: .hotelInfoUpdated, object: nil)
    }

    func newsUpdated(allNews: [(String, NewsPost)]) {
        news = []
        let _news = allNews.sorted(by: {$0.1.timestamp > $1.1.timestamp} )
        _news.forEach( { news.append($0.1) } )
        applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
    }

    func activitiesUpdated(allActivities: [(String, DailyActivities)]) {
        activities = [:]
        for a in allActivities {
            let day = a.0
            var arr:[Activity] = []
            for (key, value) in a.1 {
                var activity = value
                activity.id = key
                arr.append(activity)
            }
            activities[day] = arr.sorted(by: {$0.start.formatTimeShort() < $1.start.formatTimeShort()} )
        }
        //activities[day] = a.1.map{ var a:Activity = $0.value; a.id = $0.key}.sorted(by: {$0.start < $1.start} )
        NotificationCenter.default.post(name: .activitiesUpdated, object: nil)
    }

    func restaurantsUpdated(allRestaurants: [(String, Restaurant)]) {
        restaurants = []
        allRestaurants.forEach( {
            let r = $0.1
            r.id = $0.0
            restaurants.append(r)
        } )
        NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
        FireB.shared.subscribeForUpdates(completionHandler: self.menusUpdated)
    }
/*
    func menusUpdated(allMenus: [(String, Menu)]) {
        hotel.restaurants.forEach( {$0.menus = []} )
        hotel.roomService.menus = []
        for m in allMenus {
            if let r = hotel.restaurants.first(where: {$0.name == m.1.restaurant} ) {
                if r.menus.first(where: {$0.title == m.1.title} ) == nil {
                    r.menus.append(m.1)
                }
            }
            if m.1.restaurant == "In Room Dining" {
                hotel.roomService.menus.append(m.1)
            }
        }
        for r in hotel.restaurants {
            r.menus.sort(by: {$0.position < $1.position} )
        }
        NotificationCenter.default.post(name: .menusUpdated, object: nil)
    }
*/
    func menusUpdated(allMenus: [(String, Menu2)]) {
        hotel.restaurants.forEach( {$0.menus = []} )
        hotel.roomService.menus = []
        for m in allMenus {
            if let r = hotel.restaurants.first(where: {$0.name == m.1.restaurant} ) {
                if r.menus.first(where: {$0.title == m.1.title} ) == nil {
                    r.menus.append(m.1)
                }
            }
            if m.1.restaurant == "In Room Dining" {
                hotel.roomService.menus.append(m.1)
            }
        }
        for r in hotel.restaurants {
            r.menus.sort(by: {$0.position < $1.position} )
        }
        NotificationCenter.default.post(name: .menusUpdated, object: nil)
    }

    func translationsUpdated(allTranslations: [(String, Translations)]) {
        for l in allTranslations { translations[l.0] = l.1 }
        print(translations)
        applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
        NotificationCenter.default.post(name: .activitiesUpdated, object: nil)
        NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
    }

    func applyTranslations() {
        // find the preferred language of the device
        let lang = Locale.preferredLanguages[0].components(separatedBy: "-")[0]
        
        if let t = translations[lang] {
            for i in 0...news.count-1 {
                if let nt: [String:String] = t["news"]?[news[i].postId] {
                    if let title = nt["title"] { news[i].title = title }
                    if let subtitle = nt["subtitle"] { news[i].subtitle = subtitle }
                    if let text = nt["text"] { news[i].text = text }
                }
            }

            activities.forEach { (day: String, da: [Activity]) in
                for i in 0...da.count-1 {
                    if let nt: [String:String] = t["activities"]?[da[i].id ?? ""] {
                        if let title = nt["title"] { activities[day]?[i].title = title }
                        if let location = nt["location"] { activities[day]?[i].location = location }
                        if let text = nt["text"] { activities[day]?[i].text = text }
                    }
                }
            }

            for i in 0...restaurants.count-1 {
                if let nt: [String:String] = t["restaurants"]?[restaurants[i].id!] {
                    //if let name = nt["name"] { restaurants[i].name = name }
                    if let cuisines = nt["cuisines"] { restaurants[i].cuisines = cuisines }
                    if let location = nt["location"] { restaurants[i].location = location }
                    if let description = nt["description"] { restaurants[i].description = description }
                }
            }

        }
    }
}




var hotel = Hotel()
