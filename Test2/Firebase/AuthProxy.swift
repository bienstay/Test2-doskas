//
//  AuthProxy.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation

enum Role: String, CaseIterable {
    case superadmin
    case hoteladmin
    case editor
    case client
}

protocol AuthenticationData {
    //var userId: String
    //var userName: String
    //var displayName: String
    var uid: String { get }
    var name: String { get }
    var email: String { get }
    var role: Role? { get set }
}

protocol AuthProxy {
    func login(username: String, password: String, completionHandler: @ escaping (AuthenticationData?, Error?) -> Void)
    func addUser(username: String, password: String, role:String, completionHandler: @escaping (AuthenticationData?, Error?) -> Void)
    func logout() -> Error?

    func setUserRole(uid: String, role: Role, completionHandler: @escaping (Error?) -> Void)
    func deleteUser(uid: String, completionHandler: @ escaping (Error?) -> Void)
    func getUser(uid: String, completionHandler: @ escaping (AuthenticationData?, Error?) -> Void)
    func getUsers(hotelName: String, completionHandler: @ escaping ([AuthenticationData]) -> Void)
}
