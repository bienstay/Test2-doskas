//
//  AuthProxy.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation

struct AuthData {
    var userId: String
    var userName: String
    var displayName: String
    var role: PhoneUser.Role
}

protocol AuthProxy {
    func login(username: String, password: String, completionHandler: @ escaping (AuthData?, Error?) -> Void)
    func logout() -> Error?
}
