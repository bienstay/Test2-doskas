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
}

struct ChatRoom: Codable {
    var users:[String:Bool] = [:]
    var id: String?
    var messages:[ChatMessage]? = []
    func getUsers() -> [String] { return Array(users.keys) }
    init(id: String, users:[String:Bool]) {
        self.id = id
        self.users = users
    }
}

