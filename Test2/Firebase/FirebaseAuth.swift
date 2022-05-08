//
//  FirebaseAuth.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation
import Firebase

final class FirebaseAuthentication: AuthProxy {
    static let shared: AuthProxy = FirebaseAuthentication()
    func login(username: String, password: String, completionHandler: @escaping (AuthData?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: username, password: password) { (authResult, error) in
            guard let a = authResult else {
                Log.log(level: .ERROR, "Error logging in with user \(username) - \(error.debugDescription)")
                completionHandler(nil, error)
                return
            }
            //Log.log(level: .INFO, "Signed in with user: \(a.user.uid), \(a.user.email ?? "")" )
            // the user has sccessfully signed in, now we need to get the claims to check his role
            a.user.getIDTokenResult() { result, error in
                guard let result = result else {
                    Log.log(level: .ERROR, "Error getting claims - \(error.debugDescription)")
                    let authData = AuthData(userId: a.user.uid, userName: a.user.email ?? "", displayName: a.user.displayName ?? "", role: .none)
                    completionHandler(authData, nil)
                    return
                }
                var role: PhoneUser.Role = .none
                if let s = result.claims["role"] as? String, let r = PhoneUser.Role.init(rawValue: s) {
                    role = r
                }
                let authData = AuthData(userId: a.user.uid, userName: a.user.email ?? "", displayName: a.user.displayName ?? "", role: role)
                completionHandler(authData, nil)
            }
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
