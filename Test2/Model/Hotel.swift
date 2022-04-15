//
//  Hotel.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import UIKit

enum POIType: String, Codable {
    case Restaurant
    case Recreation
    case Administration
}

protocol POI {
    var name: String { get }
    var type: POIType { get }
    var description: String { get }
    var image: String { get }
    var geoLatitude: Double { get }
    var geoLongitude: Double { get }
    init()
}

struct Facility: POI, Codable {
    var id: String?
    var name: String = ""
    var type: POIType = .Recreation
    var description: String = ""
    var image: String = ""
    var geoLatitude: Double = 0.0
    var geoLongitude: Double = 0.0
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

struct HotelInfo: Codable {
    var name: String
    var image: String
    var socialURLs: [String:String]?
}

class Hotel {
    //var id: String = "SheratonFullMoon" // default hotel
    var id: String? = nil
    var name: String = ""
    var socialURLs: [String:String] = [:]
    var image: String = ""
    var restaurants: [Restaurant] = []
    var facilities: [Facility] = []
    var roomService: Restaurant = Restaurant()
    var destinationDining: DestinationDining = DestinationDining()
    var news: [NewsPost] = []
    var infoItems: [InfoItem] = []
    var importantNotes: [InfoItem] = []
    var roomItems: [RoomItem.ItemType : [RoomItem]] = [:]
    var activities: [Int: [Activity]] = [:]
    var offerGroups: [OfferGroup] = []
    var offers: [String:Offer] = [:]
    var translations: [String: Translations] = [:]

    func initialize() {
        roomItems = loadFromJSON(fileNameNoExt: "roomItems")
        roomService.name = "In room dining"
    }

    func startObserving() {
        dbProxy.subscribeForUpdates(completionHandler: hotelInfoUpdated)
        dbProxy.subscribeForUpdates(completionHandler: restaurantsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: facilitiesUpdated)
        dbProxy.subscribeForUpdates(completionHandler: newsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offersUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offerGroupsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offersUpdated)
        dbProxy.subscribeForUpdates(completionHandler: activitiesUpdated)
        dbProxy.subscribeForUpdates(completionHandler: translationsUpdated)
    }

    func hotelInfoUpdated(allHotelInfo: [(String, HotelInfo)]) {
        hotel.name = allHotelInfo.first?.1.name ?? "HOTEL"
        hotel.image = allHotelInfo.first?.1.image ?? ""
        hotel.socialURLs = allHotelInfo.first?.1.socialURLs ?? [:]
        NotificationCenter.default.post(name: .hotelInfoUpdated, object: nil)
    }

    func newsUpdated(allNews: [(String, NewsPost)]) {
        news = []
        let _news = allNews.sorted(by: {$0.1.timestamp > $1.1.timestamp} )
        _news.forEach( { news.append($0.1) } )
        applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
    }

    func offerGroupsUpdated(allOffers: [(String, OfferGroup)]) {
        hotel.offerGroups = allOffers.map { $0.1 }
        //applyTranslations()
        NotificationCenter.default.post(name: .offersUpdated, object: nil)
    }

    func offersUpdated(allOffers: [(String, Offer)]) {
        for pair in allOffers {
            hotel.offers[pair.0] = pair.1
            hotel.offers[pair.0]?.id = pair.0
        }
        //applyTranslations()
        NotificationCenter.default.post(name: .offersUpdated, object: nil)
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
            if let index = Activity.DOWIndex(day) {
                activities[index] = arr.sorted(by: {$0.start.formatTimeShort() < $1.start.formatTimeShort()} )
            }
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
        dbProxy.subscribeForUpdates(completionHandler: self.menusUpdated)
    }

    func facilitiesUpdated(allFacilities: [(String, Facility)]) {
        facilities = []
        allFacilities.forEach( {
            var f = $0.1
            f.id = $0.0
            facilities.append(f)
        } )
        NotificationCenter.default.post(name: .facilitiesUpdated, object: nil)
    }


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
        //print(translations)
        applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
        NotificationCenter.default.post(name: .activitiesUpdated, object: nil)
        NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
    }

    func applyTranslations() {
//        guard let lang = Locale.current.languageCode else {
//            Log.log(level: .ERROR, "languageCode is nil")
//            return
//        }

        if let t = translations[guest.lang] {
            if !news.isEmpty {
                for i in 0...news.count-1 {
                    if let nt: [String:String] = t["news"]?[news[i].postId] {
                        if let title = nt["title"] { news[i].title = title }
                        if let subtitle = nt["subtitle"] { news[i].subtitle = subtitle }
                        if let text = nt["text"] { news[i].text = text }
                    }
                }
            }

            activities.forEach { (dayIndex: Int, da: [Activity]) in
                for i in 0...da.count-1 {
                    if let nt: [String:String] = t["activities"]?[da[i].id ?? ""] {
                        if let title = nt["title"] { activities[dayIndex]?[i].title = title }
                        if let location = nt["location"] { activities[dayIndex]?[i].location = location }
                        if let text = nt["text"] { activities[dayIndex]?[i].text = text }
                    }
                }
            }

            if !restaurants.isEmpty {
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
}

struct HotelInDB: Codable {
    var id: String? = nil
    struct Info: Codable {
        var name: String = ""
        var image: String = ""
    }
    private (set) var info: Info = Info()
    private (set) var languages: [String:Bool] = [:]

    init(hotel: Hotel) {
        self.id = hotel.id
        self.info.name = hotel.name
        self.info.image = hotel.image
        self.languages = ["pl":true, "fr":true]
    }
}

extension Hotel {
    convenience init(id: String, hotelInDb: HotelInDB) {
        self.init()
        self.id = id
        self.name = hotelInDb.info.name
        self.image = hotelInDb.info.image
    }
}


var hotel = Hotel()
