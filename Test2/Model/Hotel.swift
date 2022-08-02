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
        if let t = hotel.translations.news[postId]?[phoneUser.lang]?["title"] { return t }
        else { return title }
    }
    var _subtitle: String {
        if let t = hotel.translations.news[postId]?[phoneUser.lang]?["subtitle"] { return t }
        else { return subtitle }
    }
    var _text: String {
        if let t = hotel.translations.news[postId]?[phoneUser.lang]?["text"] { return t }
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
        if let id = id, let t = hotel.translations.info[id]?[phoneUser.lang]?["title"] as? String { return t }
        else { return title }
    }
    var _subtitle: String {
        if let id = id, let t = hotel.translations.info[id]?[phoneUser.lang]?["subtitle"] as? String { return t }
        else { return subtitle }
    }
    var _text: String {
        if let id = id, let t = hotel.translations.info[id]?[phoneUser.lang]?["text"] as? String { return t }
        else { return text }
    }
    func _imageText(i: Int) -> String {
        if let id = id, let t = hotel.translations.info[id]?["images"]?[phoneUser.lang] as? [String] { return t[i] }
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

struct HotelConfigInDB: Codable {
    var name: String?
    var image: String?
    var socialURLs: [String:String]?
    var languages: [String:Bool]?
    var rooms: [String:Bool]? = [:]
    init(h: HotelConfig) {
        name = h.name
        image = h.image
        socialURLs = h.socialURLs
        var langs: [String:Bool] = [:]
        for l in h.languages { langs[l] = true }
        languages = langs
        var rr: [String:Bool] = [:]
        for r in h.rooms { rr[String(r)] = true }
        rooms = rr
    }
}

struct HotelConfig: Codable {
    var name: String = ""
    var image: String?
    var socialURLs: [String:String] = [:]
    var languages: Set<String> = []
    var rooms: Set<Int> = []
    init() {}
    init(c: HotelConfigInDB) {
        name = c.name ?? "Hotel"
        image = c.image
        socialURLs = c.socialURLs ?? [:]
        if let keys = c.languages?.keys {
            languages = Set(keys)
        }
        if let crooms = c.rooms {
            rooms = Set(crooms.keys.compactMap({ Int($0) }))
        }
    }
}


/*
struct HotelInfo: Codable {
    var name: String
    var image: String
    var socialURLs: [String:String]?
}
*/
class Hotel {
    //var id: String = "SheratonFullMoon" // default hotel
    var id: String
    var config: HotelConfig = HotelConfig()
    /*
    var name: String
    var socialURLs: [String:String] = [:]
    var image: String = ""
     */
    var restaurants: [Restaurant] = []
    var menus: [String:Menu] = [:]
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
        //name = "Appviator"
    }

    func initialize() {
        roomItems = loadFromJSON(fileNameNoExt: "roomItems")
        roomService.name = "In room dining"
    }

    deinit {
        Log.log("in hotel deinit - \(String(describing: id))", logInDb: false)
    }

    func startObserving() {
        //dbProxy.subscribeForUpdates(completionHandler: hotelInfoUpdated)
        dbProxy.subscribeForUpdates(completionHandler: hotelConfigUpdated)
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

    func hotelConfigUpdated(allHotelConfig: [String:HotelConfigInDB]) {
        if let configInDB = allHotelConfig["config"] {
            config = HotelConfig(c: configInDB)
            NotificationCenter.default.post(name: .hotelConfigUpdated, object: nil)
        }
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

    func restaurantsUpdated(allRestaurants: [String:RestaurantInDB]) {
        restaurants = []
        allRestaurants.forEach( {
            let r = Restaurant(r: $0.1)
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


    func menusUpdated(allMenus: [String:MenuInDB]) {
        //hotel.restaurants.forEach( {$0.menus = []} )
        hotel.roomService.menus = []
        if let roomServiceMenu = allMenus.first(where: { $1.name == "In Villa Dining" }) {
            hotel.roomService.menus.append(roomServiceMenu.key)
        }
        /*
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
         */
        allMenus.forEach( {
            menus[$0.key] = Menu($0.value)
        } )
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

}

var hotel = Hotel()
