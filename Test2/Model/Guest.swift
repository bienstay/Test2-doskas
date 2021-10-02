//
//  Guest.swift
//  Test2
//
//  Created by maciulek on 04/06/2021.
//

import Foundation
import Firebase

class GuestInfo: Codable {
    var Name = ""
    var roomNumber = 0
    var chatRooms: [String:Bool] = [:]
}

class Guest: Codable {
    var id: String = "MacsMaciulek" // default guest
    var Name = ""
    var roomNumber = -1
    var orders: [Order] = []
    var activeOrders: [Order] = []
    var chatRooms: [String] = []
    var chatMessages: [String:[ChatMessage]]? = [:]

    func isAdmin() -> Bool {
        return roomNumber == 0
    }

    func startObserving() {
        FireB.shared.subscribeForUpdates(parameter: .GuestInfo(id: self.id), completionHandler: guestUpdated)
        
        FireB.shared.observeOrderChanges()
    }

    func guestUpdated(allGuests: [(String, GuestInfo)]) {
        if let g = allGuests.first {
            self.Name = g.1.Name
            self.roomNumber = g.1.roomNumber
            self.chatRooms = g.1.chatRooms.keys.map({$0})
        }
        NotificationCenter.default.post(name: .guestUpdated, object: nil)
        FireB.shared.subscribeForUpdates(parameter: .OrderInDB(roomNumber: roomNumber), completionHandler: ordersUpdated)
        FireB.shared.subscribeForUpdates(parameter: .ChatRoom(id: guest.chatRooms.first!), completionHandler: self.chatMessagesUpdated)
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
        allChatMessages.forEach( {chatMessages![chatRoomId]!.append($0.1)})
        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
    }
}

var guest = Guest()
