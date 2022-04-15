//
//  FirebaseAuth.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation
import Firebase

final class FirebaseAuthentication: AuthProxy {
    static let shared: FirebaseAuthentication = FirebaseAuthentication()
    func login(username: String, password: String, completionHandler: @escaping (AuthData?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: username, password: password) { (authResult, error) in
            if let error = error {
                Log.log(level: .ERROR, "Error logging in with user \(guest.email) - \(error)")
                completionHandler(nil, error)
            }
            else {
                Log.log(level: .INFO, "Signed in with user: \(authResult?.user.uid ?? ""), \(authResult?.user.email ?? "")" )
                NotificationCenter.default.post(name: .dbProxyReady, object: nil)
                let authData = AuthData(userId: authResult?.user.uid ?? "", userName: authResult?.user.email ?? "")
                completionHandler(authData, nil)
            }
        }
    }
}
