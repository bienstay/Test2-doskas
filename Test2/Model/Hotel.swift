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

struct NewsPost: Codable {
    var postId: String = ""
    var timestamp: Date = Date()
    var imageFileURL: String = ""
    var title: String = ""
    var subtitle: String = ""
    var text: String = ""
    var _title: String {
        if let t = hotel.translations.news[phoneUser.lang]?[postId]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let t = hotel.translations.news[phoneUser.lang]?[postId]?["subtitle"] { return t }
        else { return subtitle }
    }
    var _text: String {
        if let t = hotel.translations.news[phoneUser.lang]?[postId]?["text"] { return t }
        else { return text }
    }
}

struct InfoItem: Codable {
    struct ImageData: Codable {
        var url: String
        var text: String
    }
    var id: String? = ""
    var title: String = ""
    var subtitle: String = ""
    var text: String = ""
    var timestamp: Date = Date()
    var images: [ImageData] = []
    var _title: String {
        if let id = id, let t = hotel.translations.info[phoneUser.lang]?[id]?["title"] as? String { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id, let t = hotel.translations.info[phoneUser.lang]?[id]?["subtitle"] as? String { return t }
        else { return subtitle }
    }
    var _text: String {
        if let id = id, let t = hotel.translations.info[phoneUser.lang]?[id]?["text"] as? String { return t }
        else { return text }
    }
    func _imageText(i: Int) -> String {
        if let id = id, let t = hotel.translations.info[phoneUser.lang]?[id]?["images"] as? [String] { return t[i] }
        else { return images[i].text }
    }
}

struct Review: Codable {
    var id: String?
    var timestamp: Date
    var rating: Int
    var review: String
    var roomNumber: Int?
    var userId: String?
}

struct HotelInfo: Codable {
    var name: String
    var image: String
    var socialURLs: [String:String]?
}

class Hotel {
    //var id: String = "SheratonFullMoon" // default hotel
    var id: String
    var name: String
    var socialURLs: [String:String] = [:]
    var image: String = ""
    var restaurants: [Restaurant] = []
    var facilities: [Facility] = []
    var roomService: Restaurant = Restaurant()
    var news: [NewsPost] = []
    var infoItems: [InfoItem] = []
    var importantNotes: [InfoItem] = []
    var roomItems: [RoomItem.ItemType : [RoomItem]] = [:]
    var activities: [Int: [Activity]] = [:]
    var offerGroups: [OfferGroup] = []
    var offers: [String:Offer] = [:]
    var translations: Translations = Translations()
    var likes: Likes = [:]

    init() {
        Log.log("in hotel init", logInDb: false)
        id = ""
        name = "Appviator"
    }

    func initialize() {
        roomItems = loadFromJSON(fileNameNoExt: "roomItems")
        roomService.name = "In room dining"
    }

    deinit {
        Log.log("in hotel deinit - \(String(describing: id))", logInDb: false)
    }

    func startObserving() {
        dbProxy.subscribeForUpdates(completionHandler: hotelInfoUpdated)
        dbProxy.subscribeForUpdates(completionHandler: restaurantsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: facilitiesUpdated)
        dbProxy.subscribeForUpdates(completionHandler: informationUpdated)
        dbProxy.subscribeForUpdates(completionHandler: newsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offersUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offerGroupsUpdated)
        dbProxy.subscribeForUpdates(completionHandler: offersUpdated)
        dbProxy.subscribeForUpdates(completionHandler: activitiesUpdated)
        dbProxy.subscribeForUpdates(completionHandler: likesUpdated)

        dbProxy.subscribeForUpdates(path: "content/translations/news", completionHandler: newsTranslationsUpdated)
        dbProxy.subscribeForUpdates(path: "content/translations/activities", completionHandler: activitiesTranslationsUpdated)
        dbProxy.subscribeForUpdates(path: "content/translations/restaurants", completionHandler: restaurantsTranslationsUpdated)
        dbProxy.subscribeForUpdates(path: "content/translations/offerGroups", completionHandler: offerGroupsTranslationsUpdated)
        dbProxy.subscribeForUpdates(path: "content/translations/offers", completionHandler: offersTranslationsUpdated)
        dbProxy.subscribeForUpdates(path: "content/translations/info", completionHandler: informationTranslationsUpdated)
    }

    func newsTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            translations.news = newTranslations
            NotificationCenter.default.post(name: .newsUpdated, object: nil)
        }
    }

    func activitiesTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            translations.activities = newTranslations
            NotificationCenter.default.post(name: .activitiesUpdated, object: nil)
        }
    }

    func restaurantsTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            translations.restaurants = newTranslations
            NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
        }
    }

    func offerGroupsTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            translations.offerGroups = newTranslations
            NotificationCenter.default.post(name: .offersUpdated, object: nil)
        }
    }

    func offersTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            translations.offers = newTranslations
            NotificationCenter.default.post(name: .offersUpdated, object: nil)
        }
    }

    func informationTranslationsUpdated(newTranslations: [String:Any]) {
        //if let newTranslations = newTranslations as? [String:[String:[String:Translations.InfoItemTranslated]]] {
        if let newTranslations = newTranslations as? [String:[String:[String:Any]]] {
            translations.info = newTranslations
            NotificationCenter.default.post(name: .informationUpdated, object: nil)
        }
    }

    func hotelInfoUpdated(allHotelInfo: [String:HotelInfo]) {
        hotel.name = allHotelInfo.first?.1.name ?? "HOTEL"
        hotel.image = allHotelInfo.first?.1.image ?? ""
        hotel.socialURLs = allHotelInfo.first?.1.socialURLs ?? [:]
        NotificationCenter.default.post(name: .hotelInfoUpdated, object: nil)
    }

    func informationUpdated(allInfo: [String:InfoItem]) {
        infoItems = []
        for i in allInfo {
            var ii = i.value
            ii.id = i.key
            infoItems.append(ii)
        }
        //applyTranslations()
        NotificationCenter.default.post(name: .informationUpdated, object: nil)
    }

    func newsUpdated(allNews: [String:NewsPost]) {
        news = []
        let _news = allNews.sorted(by: {$0.1.timestamp > $1.1.timestamp} )
        _news.forEach( { news.append($0.1) } )
        //applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
    }

    func offerGroupsUpdated(allOfferGroups: [String:OfferGroup]) {
        offerGroups = []
        allOfferGroups.forEach( {
            var o = $0.1
            o.id = $0.0
            offerGroups.append(o)
        } )
        NotificationCenter.default.post(name: .offersUpdated, object: nil)
    }

    func offersUpdated(allOffers: [String:Offer]) {
        for pair in allOffers {
            hotel.offers[pair.0] = pair.1
            hotel.offers[pair.0]?.id = pair.0
        }
        //applyTranslations()
        NotificationCenter.default.post(name: .offersUpdated, object: nil)
    }

    func activitiesUpdated(allActivities: [String:DailyActivities]) {
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

    func restaurantsUpdated(allRestaurants: [String:Restaurant]) {
        restaurants = []
        allRestaurants.forEach( {
            let r = $0.1
            r.id = $0.0
            restaurants.append(r)
        } )
        NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
        dbProxy.subscribeForUpdates(completionHandler: self.menusUpdated)
    }

    func facilitiesUpdated(allFacilities: [String:Facility]) {
        facilities = []
        allFacilities.forEach( {
            var f = $0.1
            f.id = $0.0
            facilities.append(f)
        } )
        NotificationCenter.default.post(name: .facilitiesUpdated, object: nil)
    }


    func menusUpdated(allMenus: [String:Menu2]) {
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

    func likesUpdated(allLikes: [String:LikesInDB]) {
        likes = [:]
        for l in allLikes {
            var countMap: [String:Int] = [:]
            for c in l.1 {
                countMap[c.key] = c.value.count
            }
            likes[l.0] = countMap
        }
        NotificationCenter.default.post(name: .likesUpdated, object: nil)
    }
    
    /*
    func translationsUpdated(allTranslations: [String:Translations]) {
        for l in allTranslations { translations[l.0] = l.1 }
        applyTranslations()
        NotificationCenter.default.post(name: .newsUpdated, object: nil)
        NotificationCenter.default.post(name: .activitiesUpdated, object: nil)
        NotificationCenter.default.post(name: .restaurantsUpdated, object: nil)
        NotificationCenter.default.post(name: .informationUpdated, object: nil)
    }

    func infoTranslationsUpdated(allTranslations: [String:InfoTranslations]) {
        //for l in allTranslations { translations[l.0] = l.1 }
        //applyTranslations()
        NotificationCenter.default.post(name: .informationUpdated, object: nil)
    }
*/
/*
    func applyTranslations() {

        if let t = translations[phoneUser.lang] {

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

            if !infoItems.isEmpty {
                for i in 0...infoItems.count-1 {
                    if let nt: [String:String] = t["information"]?[infoItems[i].id!] {
                        //if let name = nt["name"] { restaurants[i].name = name }
                        if let title = nt["title"] { infoItems[i].title = title }
                        if let subtitle = nt["subtitle"] { infoItems[i].subtitle = subtitle }
                        if let text = nt["text"] { infoItems[i].text = text }
                    }
                }
            }

        }
    }
*/
}

struct HotelInDB: Codable {
    var id: String? = nil
    struct Info: Codable {
        var name: String = ""
        var image: String = ""
    }
    private (set) var info: Info = Info()
    //private (set) var languages: [String:Bool] = [:]

    init(hotel: Hotel) {
        self.id = hotel.id
        self.info.name = hotel.name
        self.info.image = hotel.image
        //self.languages = ["pl":true, "fr":true]
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
