//
//  FirebaseFunctions.swift
//  Test2
//
//  Created by maciulek on 16/05/2022.
//

import Foundation
import Firebase


extension FirebaseAuthentication {
    func setUserRole(uid: String, role:Role, completionHandler: @ escaping (Error?) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-setUserRole").call(["uid": uid, "role": role.rawValue]) { result, error in
            if let error = error {
                Log.log(level: .ERROR, error.localizedDescription)
            }
            if let data = result?.data {
                Log.log("Data received: \(data)")
                completionHandler(nil)
            } else {
                completionHandler(error)
            }
        }
    }

    func deleteUser(uid: String, completionHandler: @ escaping (Error?) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-deleteUser").call(["uid": uid]) { result, error in
            if let error = error {
                Log.log(level: .ERROR, error.localizedDescription)
            }
            if let data = result?.data {
                Log.log("Data received: \(data)")
            }
            completionHandler(error)
        }
    }

    func updateUser(uid: String, newPassword: String, completionHandler: @ escaping (Error?) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-updateUser").call(
            ["uid": uid,
             "updates": ["password": newPassword]
            ]
        ) { result, error in
            if let error = error {
                Log.log(level: .ERROR, error.localizedDescription)
            }
            if let data = result?.data {
                Log.log("Data received: \(data)")
            }
            completionHandler(error)
        }
    }

    struct UserFromAuth: Codable {
        var uid: String
        var email: String
        struct CustomClaims: Codable {
            var role: String?
        }
        var customClaims: CustomClaims?
    }

    func getUser(uid: String, completionHandler: @ escaping (AuthenticationData?, Error?) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-getUser").call(["uid": uid]) { result, error in
            if let error = error {
                Log.log(level: .ERROR, error.localizedDescription)
                completionHandler(nil, error)
            }
            Log.log(level: .DEBUG, "Data received: \(result?.data ?? "")")
            if let data = result?.data as? NSMutableDictionary, JSONSerialization.isValidJSONObject(data) {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: data)
                    let u = try JSONDecoder().decode(UserFromAuth.self, from: jsonData)
                    let ad = FirebaseAuthenticationData(uid: u.uid, email: u.email, role: Role(rawValue: u.customClaims?.role ?? ""))
                    completionHandler(ad, nil)
                } catch {
                    completionHandler(nil, error)
                }
            } else {
                completionHandler(nil, nil)
            }
        }
    }

    func getUsers(hotelName: String, completionHandler: @ escaping ([AuthenticationData]) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-getUsers").call(["forHotel": hotelName]) { result, error in
            if let error = error {
                Log.log(level: .ERROR, error.localizedDescription)
            }
            if let data = result?.data as? [[String: String]] {
                var list:[FirebaseAuthenticationData] = []
                for u in data {
                    let a = FirebaseAuthenticationData(uid: u["uid"] ?? "", email: u["email"] ?? "", role: Role(rawValue: u["role"] ?? "") ?? .none)
                    list.append(a)
                }
                completionHandler(list)
            } else {
                completionHandler([])
            }
        }
    }
}




extension FirebaseDatabase {
    func translate(textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void) {
        Firebase.shared.functions.httpsCallable("httpFunctions-translateTextSimple").call(["text": textToTranslate, "targetLanguage": targetLanguage]) { result, error in
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    //let code = FunctionsErrorCode(rawValue: error.code)
                    //let message = error.localizedDescription
                    //let details = error.userInfo[FunctionsErrorDetailsKey]
                    Log.log(level: .ERROR, error.debugDescription)
                }
            }
            //if let data = result?.data as? [String: Any], let text = data["text"] as? String {
            if let data = result?.data as? [String: Any] {
                Log.log("translation = \(data["translation"] ?? "[empty]")")
                completionHandler(data["translation"] as? String)
            } else {
                completionHandler(nil)
            }
        }
    }

    func translateChat(chatRoom: String, chatID: String, textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void) {
        let hotelId: String = hotel.id
        let chatTranslationPath = "/hotels/\(hotelId)/chats/\(chatRoom)/\(chatID)/translations"
        Firebase.shared.functions.httpsCallable("httpFunctions-translateAndUpdateChat").call(
            ["text": textToTranslate,
             "targetLanguage": targetLanguage,
             "chatPath": chatTranslationPath
            ]) { result, error in
                if let error = error {
                    Log.log(level: .ERROR, "Error translating... - \(error.localizedDescription)")
                }
                if let data = result?.data as? String {
                    completionHandler(data)
                } else {
                    completionHandler(nil)
                }
        }
    }
}
