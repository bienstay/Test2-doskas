//
//  Guest.swift
//  Test2
//
//  Created by maciulek on 04/06/2021.
//

import Foundation
import Firebase

struct GuestInDB: Codable {
    struct PhoneInfo: Codable {
        var language: String
    }
    var roomNumber: Int = 0
    var name: String = ""
    var startDate: Date = Date()
    var endDate: Date = Date()
    var phones:[String:PhoneInfo]? = [:]
}

class GuestInfo: Codable {
    var Name = ""
    var roomNumber = 0
    var chatRooms: [String:Bool] = [:]
}

class Guest: Codable {
    var id: String = "MacsMaciulek" // default guest
    var Name = ""
    var roomNumber = 0
    var orders: [Order] = []
    var activeOrders: [Order] = []
    var chatRooms: [String] = []
    var chatMessages: [String:[ChatMessage]]? = [:]
    var unreadChatCount: Int = 0
    var likesPerUser: LikesPerUser = [:]
    var likes: Likes = [:]

    var currentLocationLongitude: Double = 0.0
    var currentLocationLatitude: Double = 0.0

    var lang: String {
        // Locale.current.languageCode returns the phone language only if the app itself is localized
        // we want to allow translations even if the app's interface is not localized
        // therefore we use the preferred language
        let preferredLang = Locale.preferredLanguages.first?.components(separatedBy: "-").first
        let localeLang = Locale.current.languageCode
        //print("LANG: \(preferredLang1)   \(preferredLang2)   \(localeLang)")
        return (preferredLang ?? localeLang ?? "en")
    }

    func isAdmin() -> Bool {
        return roomNumber == 0
    }

    func toggleLike(group: String, key: String) {
        if guest.isAdmin() { return }
        let isLiked: Bool = guest.likesPerUser[group]?.contains(key) ?? false
        dbProxy.updateLike(node: group, key: key, user: guest.id, add: !isLiked)
    }

    func numLikes(group:String, id:String) -> Int {
        if isAdmin() {
            return likes[group]?[id] ?? 0
        }
        else {
            return likesPerUser[group]?.contains(id) ?? false ? 1 : 0
        }
    }

    func updatePhoneDataInDB() {
        if let phoneID: String = UIDevice.current.identifierForVendor?.uuidString, let phoneLang: String = Locale.current.languageCode {
            dbProxy.updatePhoneData(guestId: id, phoneID: phoneID, phoneLang: phoneLang)
    /*
            dbProxy.GUESTS_DB_REF.child("/\(id)/phones/\(phoneID)/language").setValue(phoneLang) { (error, ref) in
                if let error = error {
                    Log.log(level: .ERROR, "Data could not be saved: \(error)")
                }
              }
     */
        }
    }
/*
    func startObserving() {
        dbProxy.subscribeForUpdates(parameter: .GuestInfo(id: self.id), completionHandler: guestUpdated)

        dbProxy.observeOrderChanges()
    }

    func guestUpdated(allGuests: [(String, GuestInfo)]) {
        if let g = allGuests.first {
            self.Name = g.1.Name
            self.roomNumber = g.1.roomNumber
            self.chatRooms = g.1.chatRooms.keys.map({$0})
        }
        NotificationCenter.default.post(name: .guestUpdated, object: nil)
        dbProxy.subscribeForUpdates(parameter: .OrderInDB(roomNumber: roomNumber), completionHandler: ordersUpdated)
        if let chatRoom = guest.chatRooms.first {
            dbProxy.subscribeForUpdates(parameter: .ChatRoom(id: chatRoom), completionHandler: chatMessagesUpdated)
        //dbProxy.subscribeForUpdates(parameter: .ChatRoom(id: guest.chatRooms.first!), completionHandler: chatTranslationsUpdated)
        }
*/
    func startObserving() {
        dbProxy.subscribeForUpdates(parameter: .GuestInDb(id: self.id), completionHandler: guestUpdated)

        dbProxy.observeOrderChanges()
    }

    func guestUpdated(allGuests: [(String, GuestInDB)]) {
        if let g = allGuests.first {
            self.Name = g.1.name
            self.roomNumber = g.1.roomNumber
            //self.chatRooms = g.1.chatRooms.keys.map({$0})
            self.chatRooms = ["AnitaMaciek_hotel"]
        }
        NotificationCenter.default.post(name: .guestUpdated, object: nil)
        dbProxy.subscribeForUpdates(parameter: .OrderInDB(roomNumber: roomNumber), completionHandler: ordersUpdated)
        if let chatRoom = guest.chatRooms.first {
            dbProxy.subscribeForUpdates(parameter: .ChatRoom(id: chatRoom), completionHandler: chatMessagesUpdated)
        //dbProxy.subscribeForUpdates(parameter: .ChatRoom(id: guest.chatRooms.first!), completionHandler: chatTranslationsUpdated)
        }

        if guest.isAdmin() {
            dbProxy.subscribeForUpdates(completionHandler: likesUpdated)
        } else {
            dbProxy.subscribeForUpdates(subNode: guest.id, parameter: nil, completionHandler: likesPerUserUpdated)
            guest.updatePhoneDataInDB()
        }
    }

    func likesPerUserUpdated(allLikes: [(String, LikesPerUserInDB)]) {
        likesPerUser = [:]
        // for each group create a set that contains only keys with values == True
        allLikes.forEach( { likesPerUser[$0.0] = Set($0.1.compactMap { $0.value ? $0.key : nil }) } )
        NotificationCenter.default.post(name: .likesUpdated, object: nil)
    }

    func likesUpdated(allLikes: [(String, LikesInDB)]) {
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

    func ordersUpdated(allOrders: [(String, OrderInDB)]) {
        orders = []
        allOrders.forEach({
            orders.append(Order(id: $0.0, orderInDb: $0.1))
        })
        activeOrders = orders.filter( {$0.delivered == nil && $0.canceled == nil} )
        orders.sort(by: { $0.id! > $1.id! } )
        activeOrders.sort(by: { $0.id! > $1.id! } )
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }

    func chatMessagesUpdated(allChatMessages: [(String, ChatMessage)]) {
        let chatRoomId = self.chatRooms.first!
        chatMessages![chatRoomId] = []
        unreadChatCount = 0
        allChatMessages.forEach( {
            var chatMessage = $0.1
            chatMessage.id = $0.0
            if !(chatMessage.read ?? false) { unreadChatCount += 1 }
            chatMessages![chatRoomId]!.append(chatMessage)
        })
        chatMessages![chatRoomId]!.sort(by: {$0.created < $1.created})
/*
        for m in chatMessages![chatRoomId]! {
            if m.translations?[guest.lang] == nil {
                if m.senderID != guest.id {
                    let lang = guest.lang
                    print("translating --- \(m.content) --- to \(lang)")
                    //dbProxy.translateChat(chatRoom: chatRoomId, chatID: m.id!, textToTranslate: m.content, targetLanguage: lang, completionHandler: { _ in } )
                }
            }
        }
*/
        // translate the last message
        if let m = chatMessages?[chatRoomId]?.last, m.senderID != guest.id {
            dbProxy.translateChat(chatRoom: chatRoomId, chatID: m.id!, textToTranslate: m.content, targetLanguage: lang, completionHandler: { _ in } )
        }
        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
    }
}

var guest = Guest()
