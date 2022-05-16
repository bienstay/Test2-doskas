//
//  PhoneUser.swift
//  Test2
//
//  Created by maciulek on 16/04/2022.
//

import Foundation
import UIKit    // for UIDevice

class PhoneUser {
    var guest: Guest?
    var user: User?
    var isStaff: Bool { return user != nil }
    var email: String { (isStaff ? user!.name : "appuser") + "@\(hotel.id.lowercased()).appviator.com" }
    var password: String { isStaff ? user!.password : "Appviator2022!" }
    var role: Role? { isStaff ? user!.role : .client }
    var id: String { isStaff ? user!.name : guest!.id }

    var currentLocationLongitude: Double = 0.0
    var currentLocationLatitude: Double = 0.0
    var lang: String {
        // Locale.current.languageCode returns the phone language only if the app itself is localized
        // we want to allow translations even if the app's interface is not localized
        // therefore we use the preferred language
        let preferredLang = Locale.preferredLanguages.first?.components(separatedBy: "-").first
        let localeLang = Locale.current.languageCode
        return (preferredLang ?? localeLang ?? "en")
    }

    var orders: [Order] { isStaff ? user!.orders : guest!.orders }
    var activeOrders: [Order] { isStaff ? user!.activeOrders : guest!.activeOrders }

    init() {
        guest = nil
        user = nil
        Log.log("In phoneUser init")
    }

    deinit {
        Log.log("In phoneUser deinit - \(id)", logInDb: false)
    }

    func chatRoom(charRoom: String = "") -> ChatRoom? {
        return isStaff ? user?.chatManager.getChatRoom(charRoom) : guest?.chatRoom
    }

    func unreadChatCount() -> Int {
        var count = 0
        if let user = user {
            for ch in user.chatManager.myChatRooms {
                count += ch.unreadCount
            }
        }
        if let guest = guest {
            count = guest.chatRoom.unreadCount
        }
        return count
    }

    func toString(short: Bool = false) -> String {
        if !isStaff {
            var s = String(guest!.roomNumber)
            if !guest!.name.isEmpty && !short { s = s + " - " + guest!.name }
            return s
        } else {
            var username = user!.displayName
            if username.isEmpty { username = user!.name.components(separatedBy: ".")[0] }
            return username
        }
    }

    func startObserving() {
        user?.startObserving()
        guest?.startObserving()
        updatePhoneDataInDB()
    }

    func updatePhoneDataInDB() {
        if let phoneID: String = UIDevice.current.identifierForVendor?.uuidString, let phoneLang: String = Locale.current.languageCode {
            dbProxy.updatePhoneData(guestId: id, phoneID: phoneID, phoneLang: phoneLang)
        }
    }

    func numLikes(group: String, itemKey: String) -> Int {
        let numLikes: Int
        if isStaff {
            numLikes = hotel.likes[group]?[itemKey] ?? 0
        } else {
            let found = guest?.likes[group]?.contains(itemKey)
            numLikes = found ?? false ? 1 : 0
        }
        return numLikes
    }
}

class User {
    var name: String
    var password: String
    //var role: Role = .none
    var role: Role? = nil
    var displayName: String = ""

    var orders: [Order] = []
    var activeOrders: [Order] = []
    var chatManager = ChatRoomManager()

    init(name: String, password: String, displayName: String? = nil) {
        self.name = name
        self.password = password
        if let dn = displayName { self.displayName = dn }
    }

    var id: String {
        name.components(separatedBy: ".")[0]
    }

    func startObserving() {
        dbProxy.observeOrderChanges()
        dbProxy.subscribeForUpdates(parameter: .OrderInDB(roomNumber: 0), completionHandler: ordersUpdated)
        chatManager.startObserving(userID: id)
        messagingProxy.subscribeForMessages(topic: hotel.id)
    }

    func ordersUpdated(allOrders: [String:OrderInDB]) {
        orders = []
        for o in allOrders {
            orders.append(Order(id: o.key, orderInDb: o.value))
        }
        activeOrders = orders.filter( {$0.delivered == nil && $0.canceled == nil} )
        orders.sort(by: { $0.id! > $1.id! } )
        activeOrders.sort(by: { $0.id! > $1.id! } )
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }
    
    var isOperator: Bool { return id == "operator" }
}

class Guest  {
    var roomNumber: Int
    var startDate: Date

    var id: String { String(roomNumber) + "--" + startDate.formatForDB() }
    var name = ""
    var endDate: Date = Date()

    var orders: [Order] = []
    var activeOrders: [Order] = []

    lazy var chatRoom: ChatRoom = ChatRoom(id: id, roomNumber: roomNumber)

    var likes: LikesPerUser = [:]


    init(roomNumber: Int, startDate: Date, guestName: String? = nil) {
        self.roomNumber = roomNumber
        self.startDate = startDate
        if let g = guestName { self.name = g }
    }

    func startObserving() {
        dbProxy.observeOrderChanges()
        dbProxy.subscribeForUpdates(parameter: .OrderInDB(roomNumber: roomNumber), completionHandler: ordersUpdated)
        dbProxy.subscribeForUpdates(subNode: id, parameter: nil, completionHandler: likesUpdated)
        chatRoom.startObserving()
        messagingProxy.subscribeForMessages(topic: hotel.id + "_" + id)
    }

    func toggleLike(group: String, key: String) {
        let isLiked: Bool = likes[group]?.contains(key) ?? false
        dbProxy.updateLike(group: group, userID: self.id, itemKey: key, add: !isLiked)
    }

    func ordersUpdated(allOrders: [String:OrderInDB]) {
        orders = []
        allOrders.forEach({
            orders.append(Order(id: $0.0, orderInDb: $0.1))
        })
        activeOrders = orders.filter( {$0.delivered == nil && $0.canceled == nil} )
        orders.sort(by: { $0.id! > $1.id! } )
        activeOrders.sort(by: { $0.id! > $1.id! } )
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }
    
    func likesUpdated(allLikes: [String:LikesPerUserInDB]) {
        likes = [:]
        // for each group create a set that contains only keys with values == True
        allLikes.forEach( { likes[$0.0] = Set($0.1.compactMap { $0.value ? $0.key : nil }) } )
        NotificationCenter.default.post(name: .likesUpdated, object: nil)
    }
}

var phoneUser = PhoneUser()
