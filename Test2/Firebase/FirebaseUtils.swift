//
//  FirebaseUtils.swift
//  Test2
//
//  Created by maciulek on 03/06/2021.
//

import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFunctions

extension FireB {

    // need a special function to know which specific order has been updated
    func observeOrderChanges() {
        observed.insert(ORDERS_DB_REF)
        ORDERS_DB_REF.observe(.childChanged, with: { (snapshot) in
            
            let decoder = JSONDecoder()
            if JSONSerialization.isValidJSONObject(snapshot.value!) {
                let data = try? JSONSerialization.data(withJSONObject: snapshot.value!)
                do {
                    let orderFromDB: OrderInDB = try decoder.decode(OrderInDB.self, from: data!)
                    let order = Order(id: snapshot.key, orderInDb: orderFromDB)
                    Log.log(level: .INFO, "Order \(order.number) updated")
                    if !guest.isAdmin() {
                        prepareNotification(id: String(order.number), title: "ORDER", subtitle: String(order.number), body: order.status.toString(), attachmentFile: "RoomService")
                    }
                } catch {
                    Log.log(level: .ERROR, "Failed to decode JSON")
                    Log.log(level: .ERROR, snapshot.debugDescription)
                    Log.log(level: .ERROR, "\(error)")
                }
            }
        })
    }

    func getHotels(completionHandler: @ escaping ([String:String]) -> Void) {
        let hotelsRef = ROOT_DB_REF.child("config").child("hotels")
        hotelsRef.getData { (error, snapshot) in
            if let error = error {
                Log.log("Error getting data \(error)")
            } else {
                if let data = snapshot.value as? [String:String] {
                    completionHandler(data)
                }
            }
        }
    }

    func getGuests(hotelID: String, index: Int, completionHandler: @ escaping (Int, [(String, GuestInfo)]) -> Void) {
        let guestsRef = ROOT_DB_REF.child("hotels").child(hotelID).child("users")
        guestsRef.getData { (error, snapshot) in
            if let error = error {
                Log.log("Error getting data \(error)")
            } else {
                let data: [(String, GuestInfo)] = self.decodeSnapshot(snapshot: snapshot)
                completionHandler(index, data)
            }
        }
    }

    func updateOrderStatus(orderId: String, newStatus: Order.Status, confirmedBy: String? = nil, deliveredBy: String? = nil, canceledBy: String? = nil) {
        let orderRef = ORDERS_DB_REF.child("/\(orderId)")
        var key = ""
        switch newStatus {
        case .CREATED: key = "created"
        case .CANCELED: key = "canceled"
        case .CONFIRMED: key = "confirmed"
        case .DELIVERED: key = "delivered"
        }
        var childUpdates:[String : Any] = [key: Date().timeIntervalSince1970]
        if let name = confirmedBy {
            childUpdates["confirmedBy"] = name
        }
        if let name = deliveredBy {
            childUpdates["deliveredBy"] = name
        }
        if let name = canceledBy {
            childUpdates["canceledBy"] = name
        }

        orderRef.updateChildValues(childUpdates) { (error, dbref) in
            if let error = error {
                Log.log(level: .ERROR, "Error getting data \(error)")
            }
        }
    }

    func updateLike(node: String, key: String, user: String, add: Bool) {
        let dbRef = LIKES_DB_REF
        let childUpdates:[String : Any] = [
            "/global/\(node)/\(key)/count" : ServerValue.increment(add ? 1 : -1),
            "/perUser/\(user)/\(node)/\(key)" : (add ? true : false)
        ]

//        guard let key = ref.child("posts").childByAutoId().key else { return }
//        let post = ["uid": userID,
//                    "author": username,
//                    "title": title,
//                    "body": body]
//        let childUpdates = ["/posts/\(key)": post,
//                            "/user-posts/\(userID)/\(key)/": post]

        dbRef.updateChildValues(childUpdates) { (error, dbref) in
            if let error = error {
                Log.log(level: .ERROR, "Error getting data \(error)")
            }
        }
    }

}

extension FireB {
    func translate(textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void) {
        functions.httpsCallable("translateTextSimple").call(["text": textToTranslate, "targetLanguage": targetLanguage]) { result, error in
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
                print(data)
                completionHandler(data["translation"] as? String)
            } else {
                completionHandler(nil)
            }
        }
    }

    func translateChat(chatRoom: String, chatID: String, textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void) {
        let hotelId: String = hotel.id!
        let chatTranslationPath = "/hotels/\(hotelId)/chats/messages/\(chatRoom)/\(chatID)/translations"
        functions.httpsCallable("translateAndUpdateChat").call(
            ["text": textToTranslate,
             "targetLanguage": targetLanguage,
             "chatPath": chatTranslationPath
            ]) { result, error in
                if let error = error {
                    Log.log(level: .ERROR, "Error translating... - \(error)")
                }
                if let data = result?.data {
                    print(data)
                    completionHandler("Ok")
                } else {
                    completionHandler(nil)
                }
            }
    }

    func markChatAsRead(chatRoom: String, chatID: String) {
        CHAT_MESSAGES_DB_REF.child(chatRoom).child(chatID).child("read").setValue(true)
    }

    func addHotelToConfig(hotelId: String, hotelName: String) {
        CONFIG_DB_REF.child("hotels").child(hotelId).setValue(hotelName)
    }

    func updatePhoneData(guestId: String, phoneID: String, phoneLang: String) {
        GUESTSNEW_DB_REF.child("/\(guestId)/phones/\(phoneID)/language").setValue(phoneLang) { (error, ref) in
            if let error = error {
                Log.log(level: .ERROR, "Data could not be saved: \(error)")
            }
          }
    }

    func t1() {
        functions.httpsCallable("t1").call() {result, error in
            if let error = error {
                Log.log(level: .ERROR, "Error translating... - \(error)")
            }
            if let data = result?.data {
                print(data)
            }
        }
    }

    func updateGuest(guestId: String, guestData: GuestInDB) {
        if let g = convertObjectToDictionary(t: guestData) {
            let updates = [
                "/guests/\(guestId)": g,
                "/rooms/\(guestData.roomNumber)/currentGuest": guestId
            ] as [String : Any]
            HOTEL_DB_REF.updateChildValues(updates)  { (error, dbref) in
                if let error = error {
                    Log.log(level: .ERROR, "Error updating data \(guestData)\n\(error)")
                }
            }
        }
    }
}
