//
//  AuthProxy.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation

enum Role: String {
    case superadmin
    case hoteladmin
    case editor
    case client
    case none
}

struct AuthData {
    var userId: String
    var userName: String
    var displayName: String
    var role: Role
}

protocol AuthProxy {
    func login(username: String, password: String, completionHandler: @ escaping (AuthData?, Error?) -> Void)
    func addUser(username: String, password: String, role:String, completionHandler: @escaping (AuthData?, Error?) -> Void)
    func logout() -> Error?
}
