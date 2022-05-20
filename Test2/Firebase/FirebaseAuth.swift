//
//  FirebaseAuth.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation
import Firebase

struct FirebaseAuthenticationData: AuthenticationData {
    private(set) var uid: String
    private(set) var name: String {
        get { String(email.split(separator: "@")[0]) }
        set(newName) { email = newName + "@" + hotel.id + ".appviator.com" }
    }
    private(set) var email: String
    var role: Role?
}


final class FirebaseAuthentication: AuthProxy {
    static let shared: AuthProxy = FirebaseAuthentication()
    var defaultPassword:String  { hotel.id.lowercased() }

    func login(username: String, password: String, completionHandler: @escaping (AuthenticationData?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: username, password: password) { (authResult, error) in
            guard let a = authResult else {
                Log.log(level: .ERROR, "Error logging in with user \(username) - \(error.debugDescription)")
                completionHandler(nil, error)
                return
            }
            Log.log(level: .INFO, "Signed in with user: \(a.user.uid), \(a.user.email ?? "")" )
            // the user has sccessfully signed in, now we need to get the claims to check his role
            a.user.getIDTokenResult() { result, error in
                let email: String = a.user.email ?? ""
                var role: Role?
                if let result = result, let s = result.claims["role"] as? String, let r = Role(rawValue: s) {
                        role = r
                } else {
                    Log.log(level: .ERROR, "Error getting claims - \(error.debugDescription)")
                }
                let authData = FirebaseAuthenticationData(uid: a.user.uid, email: email, role: role)
                completionHandler(authData, nil)
            }
        }
    }

    func addUser(username: String, password: String, role:String, completionHandler: @escaping (AuthenticationData?, Error?) -> Void) {
        let username = username + "@\(hotel.id).appviator.com"
        Auth.auth().createUser(withEmail: username, password: password) { (authDataResult, error) in
            guard let a = authDataResult else {
                Log.log(level: .ERROR, "Error logging in with user \(username) - \(error.debugDescription)")
                completionHandler(nil, error)
                return
            }
            Log.log("User added: \(a.user)")
            completionHandler(FirebaseAuthenticationData(uid: a.user.uid, email: a.user.email ?? "", role: Role(rawValue: role) ?? .none), nil)
        }
    }

    func logout() -> Error? {
        do {
            try Auth.auth().signOut()
            return nil
        } catch {
            Log.log(level: .ERROR, "Error in logout: \(error)")
            return error
        }
    }
}
