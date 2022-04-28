//
//  PhoneUser.swift
//  Test2
//
//  Created by maciulek on 16/04/2022.
//

import Foundation
import UIKit    // for UIDevice

class PhoneUser {
    enum Role: String {
        case superadmin
        case hoteladmin
        case editor
        case client
        case none
    }
    var guest: Guest? = nil
    var user: User? = nil
    var isStaff: Bool { return user != nil }
    var email: String { (isStaff ? user!.name : "appuser") + "@\(hotel.id!.lowercased()).appviator.com" }
    var password: String { isStaff ? user!.password : "Appviator2022!" }
    var role: Role { isStaff ? user!.role : .client }
    var id: String { isStaff ? user!.name : guest!.id }

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

    var orders: [Order] { isStaff ? user!.orders : guest!.orders }
    var activeOrders: [Order] { isStaff ? user!.activeOrders : guest!.activeOrders }

    func chatMessages(chatRoom: String = "") -> [ChatMessage] {
        var msgs: [ChatMessage] = []
        if isStaff {
            msgs = user!.chatManager.getChatRoom(chatRoom).messages
            /*
            if let index = user!.myChatRooms.firstIndex(where: {$0.id == chatRoom}) {
                msgs = user?.myChatRooms[index].messages ?? []
            }
            */
        }
        else { msgs = guest?.chatMessages ?? [] }
        return msgs
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
    var role: PhoneUser.Role = .none
    var displayName: String = ""

    var orders: [Order] = []
    var activeOrders: [Order] = []
    //var chatMessages: [String:[ChatMessage]] = [:]
    //var unreadChatCount: Int = 0
    //var myChatRooms: [ChatRoom] = []
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
        //dbProxy.subscribeForUpdates(subNode: nil, parameter: .AssignedTo(id: id), completionHandler: chatRoomsUpdated)
        //dbProxy.subscribeForUpdates(subNode: "9104--20220319-07:38:24", parameter: nil/*.AssignedTo(id: "boss")*/, completionHandler: chatMessagesUpdated)
        chatManager.startObserving(userID: id)

        messagingProxy.subscribeForMessages(topic: hotel.id ?? "")
    }

    func ordersUpdated(allOrders: [(String, OrderInDB)], subNode: String?) {
        orders = []
        allOrders.forEach({
            orders.append(Order(id: $0.0, orderInDb: $0.1))
        })
        activeOrders = orders.filter( {$0.delivered == nil && $0.canceled == nil} )
        orders.sort(by: { $0.id! > $1.id! } )
        activeOrders.sort(by: { $0.id! > $1.id! } )
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }
/*
    func chatRoomsUpdated(allChatRooms: [(String, ChatRoomInDB)], subNode: String?) {
        print(allChatRooms)
        for room in allChatRooms {
            myChatRooms.append(ChatRoom(id: room.0))
        }
    }

    func chatMessagesUpdated(allChatMessages: [(String, ChatMessage)], subNode: String?) {
        guard let chatRoomId = subNode else {
            Log.log(level: .ERROR, "subNode empty in chatMessagesUpdated")
            return
        }
        guard let index = myChatRooms.firstIndex(where: {$0.id == chatRoomId}) else {
            Log.log(level: .ERROR, "chatRoom \(chatRoomId) not found ")
            return
        }
        myChatRooms[index].messages = []
        //unreadChatCount = 0
        for m in allChatMessages {
            var chatMessage = m.1
            chatMessage.id = m.0
            //if !(chatMessage.read ?? false) { unreadChatCount += 1 }
            myChatRooms[index].messages.append(chatMessage)
        }
        myChatRooms[index].messages.sort(by: {$0.created < $1.created})
        // translate the last message

        if let m = myChatRooms[index].messages.last, m.senderID != phoneUser.id {
            dbProxy.translateChat(chatRoom: chatRoomId, chatID: m.id!, textToTranslate: m.content, targetLanguage: phoneUser.lang, completionHandler: { _ in } )
        }

        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
    }
*/
}

class Guest  {
    var roomNumber: Int
    var startDate: Date

    var id: String { String(roomNumber) + "--" + startDate.formatForDB() }
    var name = ""
    var endDate: Date = Date()

    var orders: [Order] = []
    var activeOrders: [Order] = []
    //var chatMessages: [String:[ChatMessage]] = [:]
    var chatMessages: [ChatMessage] = []
    var unreadChatCount: Int = 0
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
        dbProxy.subscribeForUpdates(subNode: id, parameter: nil, completionHandler: chatMessagesUpdated)

        messagingProxy.subscribeForMessages(topic: (hotel.id ?? "") + "_" + String(roomNumber))
    }

    func toggleLike(group: String, key: String) {
        let isLiked: Bool = likes[group]?.contains(key) ?? false
        dbProxy.updateLike(group: group, userID: self.id, itemKey: key, add: !isLiked)
    }

    func ordersUpdated(allOrders: [(String, OrderInDB)], subNode: String?) {
        orders = []
        allOrders.forEach({
            orders.append(Order(id: $0.0, orderInDb: $0.1))
        })
        activeOrders = orders.filter( {$0.delivered == nil && $0.canceled == nil} )
        orders.sort(by: { $0.id! > $1.id! } )
        activeOrders.sort(by: { $0.id! > $1.id! } )
        NotificationCenter.default.post(name: .ordersUpdated, object: nil)
    }
    
    func likesUpdated(allLikes: [(String, LikesPerUserInDB)], subNode: String?) {
        likes = [:]
        // for each group create a set that contains only keys with values == True
        allLikes.forEach( { likes[$0.0] = Set($0.1.compactMap { $0.value ? $0.key : nil }) } )
        NotificationCenter.default.post(name: .likesUpdated, object: nil)
    }

    func chatMessagesUpdated(allChatMessages: [(String, ChatMessage)], subNode: String?) {
        //let chatRoomId = id
        //chatMessages[chatRoomId] = []
        chatMessages = []
        unreadChatCount = 0
        allChatMessages.forEach( {
            var chatMessage = $0.1
            chatMessage.id = $0.0
            if !(chatMessage.read ?? false) { unreadChatCount += 1 }
            chatMessages.append(chatMessage)
        })
        chatMessages.sort(by: {$0.created < $1.created})
        // translate the last message
        if let m = chatMessages.last, m.senderID != phoneUser.id {
            dbProxy.translateChat(chatRoom: id, chatID: m.id!, textToTranslate: m.content, targetLanguage: phoneUser.lang, completionHandler: { _ in } )
        }

        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
    }

}

var phoneUser = PhoneUser()
