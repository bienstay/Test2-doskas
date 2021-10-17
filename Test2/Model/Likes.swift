//
//  Likes.swift
//  Test2
//
//  Created by maciulek on 16/10/2021.
//

import Foundation

typealias LikesPerUser = [String:Set<String>]
typealias LikesPerUserInDB = [String : Bool]

typealias Likes = [String: [String:Int]]

struct PerItem: Codable {
    var count: Int = 0
}
typealias LikesInDB = [String : PerItem]
//typealias LikesInDB = [String : [String:Int]]

/*
struct LikesInDbb: Codable {
    struct PerItem: Codable {
        var count: Int = 0
    }
    var likes: [String:PerItem]
}
*/
