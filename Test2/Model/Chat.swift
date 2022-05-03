//
//  Chat.swift
//  Test2
//
//  Created by maciulek on 15/07/2021.
//

import Foundation

struct ChatMessage: Codable {
    let created: Date
    let content: String
    let senderID: String
    let senderName: String
    let isSenderStaff: Bool?  // to do - should not be optional, temp only for old messages
    var translations: [String:String]? = nil
    var id: String?
    var read: Bool?
    var chatRoomID: String?
}

struct ChatRoomInDB: Codable {
    var roomNumber: Int
    var assignedTo: String?
}

class ChatRoom {
    var id: String
    var unreadCount: Int = 0
    var assignedTo: String = "operator"
    //weak var newObserverHandle: NSObject? = nil
    //weak var modifiedObserverHandle: NSObject? = nil
    //weak var observerHandle: NSObject? = nil
    var messages:[ChatMessage]
    
    init(id: String, assignedTo: String?) {
        print("in ChatRoom init")
        self.id = id
        if let assignedTo = assignedTo { self.assignedTo = assignedTo }
        messages = []
    }
    
    deinit {
        print("in ChatRoom deinit")
        stopObserving()
    }

    func startObserving() {
        /*
        if observerHandle == nil {
            observerHandle = dbProxy.subscribeForUpdates(subNode: id, parameter: nil, completionHandler: chatMessagesUpdated)
        }
         */

        dbProxy.subscribeForNew(subNode: id, parameter: nil, completionHandler: chatMessageAdded)
        dbProxy.subscribeForModified(subNode: id, parameter: nil, completionHandler: chatMessageUpdated)
    }
    
    func stopObserving() {
        dbProxy.unsubscribe(t: ChatMessage.self, subNode: id)
        //dbProxy.unsubscribe(handle: observerHandle)
    }

    func chatMessageAdded(key:String, messageInDB: ChatMessage) {
        var m = messageInDB
        m.id = key
        messages.append(m)
        NotificationCenter.default.post(name: .chatMessagesUpdated, object: m)
        if m.senderID != phoneUser.id {
            dbProxy.translateChat(chatRoom: id, chatID: m.id!, textToTranslate: m.content, targetLanguage: phoneUser.lang, completionHandler: { _ in } )
            updateUnreadCount()
        }
    }

    func chatMessageDeleted(key: String, messageInDB: ChatMessage) {
        if let i = messages.firstIndex(where: { $0.id == key }) {
            messages.remove(at: i)
            NotificationCenter.default.post(name: .chatMessagesUpdated, object: i)
        }
    }

    func chatMessageUpdated(key: String, messageInDB: ChatMessage) {
        var newMessage = messageInDB
        newMessage.id = key
        if let i = messages.firstIndex(where: { $0.id == key }) {
            messages[i] = newMessage
            NotificationCenter.default.post(name: .chatMessagesUpdated, object: i)
            updateUnreadCount()
        }
    }
    
    func updateUnreadCount() {
        unreadCount = 0
        for m in messages {
            if !(m.read ?? false) {
                unreadCount += 1
            }
        }
    }
/*
    func chatMessagesUpdated(allChatMessages: [(String, ChatMessage)], subNode: String?) {
        guard let chatRoomId = subNode else {
            Log.log(level: .ERROR, "subNode empty in chatMessagesUpdated")
            return
        }
        guard chatRoomId == id else {
            Log.log(level: .ERROR, "subNode different than id empty in chatMessagesUpdated")
            return
        }
        messages = []
        unreadCount = 0
        for m in allChatMessages {
            var chatMessage = m.1
            chatMessage.id = m.0
            if !(chatMessage.read ?? false) { unreadCount += 1 }
            messages.append(chatMessage)
        }
        messages.sort(by: {$0.created < $1.created})
        // translate the last message
        if let m = messages.last, m.senderID != phoneUser.id {
            let lang = phoneUser.lang
            if m.translations == nil || m.translations?[lang] == nil {
                Log.log("translating \(m.content) to \(lang)")
                dbProxy.translateChat(chatRoom: chatRoomId, chatID: m.id!, textToTranslate: m.content, targetLanguage: lang, completionHandler: { _ in } )
            }
        }

        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
    }
*/
}

class ChatRoomManager {
    var myChatRooms: [ChatRoom] = []

    var chatRoomCount: Int {
        myChatRooms.count
    }

    func getChatRoom(_ index: Int) -> ChatRoom {
        return myChatRooms[index]
    }
    func getChatRoom(_ id: String) -> ChatRoom {
        guard let index = myChatRooms.firstIndex(where: {$0.id == id}) else {
            return ChatRoom(id: "", assignedTo: "")
        }
        return myChatRooms[index]
    }

    func startObserving(userID: String) {
        //dbProxy.subscribeForUpdates(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomsUpdated)
        dbProxy.subscribeForNew(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomAdded)
        dbProxy.subscribeForDeleted(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomRemoved)
        dbProxy.subscribeForModified(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomUpdated)
    }

    func chatRoomAdded(key: String, chatRoom: ChatRoomInDB) {
        let newChatRoom = ChatRoom(id: key, assignedTo: chatRoom.assignedTo)
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

    func chatRoomUpdated(key: String, chatRoom: ChatRoomInDB) {
        if let i = myChatRooms.firstIndex(where: { $0.id == key }) {
            myChatRooms[i].assignedTo = chatRoom.assignedTo ?? "operator"
            NotificationCenter.default.post(name: .chatRoomsUpdated, object: nil)
        }
    }

/*
    func chatRoomsUpdated(allChatRooms: [(String, ChatRoomInDB)], subNode: String?) {
        for r in myChatRooms {
            r.stopObserving()
        }
        myChatRooms = []
        for room in allChatRooms {
            let chatRoom = ChatRoom(id: room.0, assignedTo: room.1.assignedTo)
            myChatRooms.append(chatRoom)
            chatRoom.startObserving()
        }
        myChatRooms.sort(by: {$0.id < $1.id} )
    }
*/
}
