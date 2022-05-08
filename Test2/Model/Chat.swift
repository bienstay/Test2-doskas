//
//  Chat.swift
//  Test2
//
//  Created by maciulek on 15/07/2021.
//

import Foundation

struct ChatMessage: Codable {
    var id: String?
    let created: Date
    let content: String
    let senderID: String
    let senderName: String
    let isSenderStaff: Bool
    let chatRoomID: String
    var translations: [String:String]? = nil
    var read: Bool?
}

struct ChatRoomInDB: Codable {
    var roomNumber: Int
    var assignedTo: String?
}

class ChatRoom {
    var id: String
    var roomNumber: Int
    var unreadCount: Int = 0
    var assignedTo: String = "operator"
    var messages:[ChatMessage]

    init(id: String, roomNumber:Int, assignedTo: String?) {
        self.id = id
        self.roomNumber = roomNumber
        if let assignedTo = assignedTo { self.assignedTo = assignedTo }
        messages = []
    }

    deinit {
        stopObserving()
    }

    func startObserving() {
        dbProxy.subscribeForNew(subNode: id, parameter: nil, completionHandler: chatMessageAdded)
        dbProxy.subscribeForDeleted(subNode: id, parameter: nil, completionHandler: chatMessageDeleted)
        dbProxy.subscribeForModified(subNode: id, parameter: nil, completionHandler: chatMessageUpdated)
    }

    func stopObserving() {
        dbProxy.unsubscribe(t: ChatMessage.self, subNode: id)
    }

    func chatMessageAdded(key:String, messageInDB: ChatMessage) {
        var m = messageInDB
        m.id = key
        messages.append(m)
        NotificationCenter.default.post(name: .chatMessageAdded, object: m)
        if m.senderID != phoneUser.id {
            dbProxy.translateChat(chatRoom: id, chatID: m.id!, textToTranslate: m.content, targetLanguage: phoneUser.lang, completionHandler: { _ in } )
            updateUnreadCount()
        }
    }

    func chatMessageDeleted(key: String, messageInDB: ChatMessage) {
        if let i = messages.firstIndex(where: { $0.id == key }) {
            messages.remove(at: i)
            NotificationCenter.default.post(name: .chatMessageDeleted, object: i)
            updateUnreadCount()
        }
    }

    func chatMessageUpdated(key: String, messageInDB: ChatMessage) {
        if let i = messages.firstIndex(where: { $0.id == key }) {
            var m = messageInDB
            m.id = key
            messages[i] = m
            NotificationCenter.default.post(name: .chatMessageUpdated, object: m)
            updateUnreadCount()
        }
    }
    
    func updateUnreadCount() {
        unreadCount = 0
        for m in messages {
            if m.senderID != phoneUser.id && m.isSenderStaff != phoneUser.isStaff && !(m.read ?? false) {
                unreadCount += 1
            }
        }
    }
}

class ChatRoomManager {
    var myChatRooms: [ChatRoom] = []

    var chatRoomCount: Int {
        myChatRooms.count
    }

    func getChatRoom(_ index: Int) -> ChatRoom {
        return myChatRooms[index]
    }
    func getChatRoom(_ id: String) -> ChatRoom? {
        guard let index = myChatRooms.firstIndex(where: {$0.id == id}) else {
            //return ChatRoom(id: "", roomNumber: 0, assignedTo: "")
            return nil
        }
        return myChatRooms[index]
    }

    func startObserving(userID: String) {
        dbProxy.subscribeForNew(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomAdded)
        dbProxy.subscribeForDeleted(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomRemoved)
        dbProxy.subscribeForModified(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomUpdated)
    }
    
    func stopObserving(userID: String) {
        dbProxy.unsubscribe(t: ChatRoomInDB.self, subNode: nil)
    }

    func chatRoomAdded(key: String, chatRoom: ChatRoomInDB) {
        let newChatRoom = ChatRoom(id: key, roomNumber: chatRoom.roomNumber, assignedTo: chatRoom.assignedTo)
        newChatRoom.startObserving()
        myChatRooms.append(newChatRoom)
        NotificationCenter.default.post(name: .chatRoomsUpdated, object: nil)
    }

    func chatRoomRemoved(key: String, chatRoom: ChatRoomInDB) {
        guard let index = myChatRooms.firstIndex(where: {$0.id == key}) else { return }
        myChatRooms[index].stopObserving()
        myChatRooms.remove(at: index)
        NotificationCenter.default.post(name: .chatRoomsUpdated, object: nil)
    }

    func chatRoomUpdated(key: String, chatRoom: ChatRoomInDB) { // only copy assignedTo field
        if let i = myChatRooms.firstIndex(where: { $0.id == key }) {
            myChatRooms[i].assignedTo = chatRoom.assignedTo ?? "operator"
        }
        NotificationCenter.default.post(name: .chatRoomsUpdated, object: nil)
    }
}
