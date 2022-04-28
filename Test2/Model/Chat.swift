//
//  Chat.swift
//  Test2
//
//  Created by maciulek on 15/07/2021.
//

import Foundation

struct ChatMessage: Codable {
    var created: Date = Date()
    var content: String = ""
    var senderID: String = ""
    var senderName: String = ""
    var translations: [String:String]? = nil
    var id: String?
    var read: Bool?
}

struct ChatRoomInDB: Codable {
    var assignedTo: String?
}

class ChatRoom {
    var id: String
    var unreadCount: Int = 0
    var assignedTo: String = "operator"
    var observerHandle: NSObject? = nil
    var messages:[ChatMessage]
    
    init(id: String, assignedTo: String?) {
        self.id = id
        if let assignedTo = assignedTo { self.assignedTo = assignedTo }
        messages = []
    }
    
    deinit {
        stopObserving()
    }

    func startObserving() {
        if observerHandle == nil {
            observerHandle = dbProxy.subscribeForUpdates(subNode: id, parameter: nil, completionHandler: chatMessagesUpdated)
        }
    }
    
    func stopObserving() {
        dbProxy.unsubscribe(handle: observerHandle)
    }

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
            dbProxy.translateChat(chatRoom: chatRoomId, chatID: m.id!, textToTranslate: m.content, targetLanguage: phoneUser.lang, completionHandler: { _ in } )
        }

        NotificationCenter.default.post(name: .chatMessagesUpdated, object: nil)
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
    func getChatRoom(_ id: String) -> ChatRoom {
        guard let index = myChatRooms.firstIndex(where: {$0.id == id}) else {
            return ChatRoom(id: "", assignedTo: "")
        }
        return myChatRooms[index]
    }

    func startObserving(userID: String) {
        dbProxy.subscribeForUpdates(subNode: nil, parameter: userID == "operator" ? nil : .AssignedTo(id: userID), completionHandler: chatRoomsUpdated)
    }

    func chatRoomsUpdated(allChatRooms: [(String, ChatRoomInDB)], subNode: String?) {
        myChatRooms = []
        for room in allChatRooms {
            let chatRoom = ChatRoom(id: room.0, assignedTo: room.1.assignedTo)
            myChatRooms.append(chatRoom)
            chatRoom.startObserving()
        }
        myChatRooms.sort(by: {$0.id < $1.id} )
    }
}
