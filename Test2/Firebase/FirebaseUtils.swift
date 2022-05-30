//
//  FirebaseUtils.swift
//  Test2
//
//  Created by maciulek on 03/06/2021.
//

import Foundation
import Firebase
import FirebaseDatabase


extension FirebaseDatabase {

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
                    if !phoneUser.isStaff {
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
                Log.log("Error getting hotel data \(error)")
            } else {
                if let data = snapshot.value as? [String:String] {
                    completionHandler(data)
                }
            }
        }
    }
/*
    func getGuests(hotelID: String, index: Int, completionHandler: @ escaping (Int, [(String, GuestInfo)]) -> Void) {
        let guestsRef = ROOT_DB_REF.child("hotels").child(hotelID).child("users")
        guestsRef.getData { (error, snapshot) in
            if let error = error {
                Log.log("Error getting guest data \(error)")
            } else {
                let data: [(String, GuestInfo)] = self.decodeSnapshot(snapshot: snapshot)
                completionHandler(index, data)
            }
        }
    }
*/
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
                Log.log(level: .ERROR, "Error updating order status \(error.localizedDescription)")
            }
        }
    }

    func updateLike(group: String, userID: String, itemKey: String, add: Bool) {
        let dbRef = LIKES_DB_REF
        let childUpdates:[String : Any] = [
            "/global/\(group)/\(itemKey)/count" : ServerValue.increment(add ? 1 : -1),
            "/perUser/\(userID)/\(group)/\(itemKey)" : (add ? true : false)
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
                Log.log(level: .ERROR, "Error updating likes \(error.localizedDescription)")
            }
        }
    }

}

extension FirebaseDatabase {
    func markChatAsRead(chatRoom: String, chatID: String) {
        CHATS_DB_REF.child(chatRoom).child(chatID).child("read").setValue(true) { (error, ref) -> Void in
            if let error = error {
                Log.log(level: .ERROR, "Error marking chat as read - \(error.localizedDescription)")
            }
        }
    }

    func updatePhoneData(phoneUserId: String, phoneID: String, phoneLang: String) {
        let phoneData = [ "phoneUserId": phoneUserId, "roomNumber": phoneUser.roomNumber ?? 0, "language": phoneLang] as [String : Any]
        PHONES_DB_REF.child(phoneID).setValue(phoneData) { (error, ref) -> Void in
            if let error = error {
                Log.log(level: .ERROR, "Error updating phone data - \(error.localizedDescription)")
            }
        }
    }
/*
    func updateGuest(hotelId: String, guestId: String, guestData: GuestInDB, completionHandler: @ escaping () -> Void) {
        if let g = convertObjectToDictionary(t: guestData) {
            let updates = [
                "/guests/\(guestId)": g,
                "/rooms/\(guestData.roomNumber)/currentGuest": guestId
            ] as [String : Any]
            Auth.auth().signIn(withEmail: "appuser@appviator.com", password: "Appviator2022!") { (authResult, error) in
                self.ROOT_DB_REF.child("hotels").child(hotelId).updateChildValues(updates)  { (error, dbref) in
                    if let error = error {
                        Log.log(level: .ERROR, "Error updating data \(guestData)\n\(error.localizedDescription)")
                    } else {
                        completionHandler()
                    }
                }
            }
        }
    }
*/
    func observeInfo() {
        DBINFO_DB_REF.observe(.value, with: { snapshot in
            if let info = snapshot.value as? NSDictionary {
                self.isConnected = info["connected"] as? Bool ?? false
                self.serverTimeOffet = info["serverTimeOffset"] as? Double ?? 0.0
                NotificationCenter.default.post(name: .connectionStatusUpdated, object: nil)
            }
        })
    }

    func log(level: Log.LogLevel = .INFO, s: String) {
/*
        Analytics.logEvent("share_image", parameters: [
            "name": name as NSObject,
            "full_text": text as NSObject,
        ])
*/

        let phoneID = UIDevice.current.identifierForVendor?.uuidString
        let e = LogInDB(text: s)
        if let json = try? JSONEncoder().encode(e), let dictionary = try? JSONSerialization.jsonObject(with: json) {
            LOGS_DB_REF.child(phoneID ?? "phone").child(Date().formatFull()).setValue(dictionary)
        }
    }

    func writeChat(chatRoomID: String, message m: ChatMessage) {
        _ = dbProxy.addRecord(key: nil, subNode: chatRoomID, record: m) { _, _ in }
        if !phoneUser.isStaff, let roomNumber = phoneUser.roomNumber, let roomNumberAsInt = Int(roomNumber) {
            CHATROOMS_DB_REF.child(chatRoomID).child("roomNumber").setValue(roomNumberAsInt) { (error, ref) -> Void in
                if let error = error {
                    Log.log(level: .ERROR, "Error updating chat room - \(error.localizedDescription)")
                }
            }
        }
    }
    
    func assignChat(chatRoom: String, to user: String) {
        CHATROOMS_DB_REF.child(chatRoom).child("assignedTo").setValue(user) { (error, ref) -> Void in
            if let error = error {
                Log.log(level: .ERROR, "Error marking chat as read - \(error.localizedDescription)")
            }
        }
    }

    func changePassword(oldPassword: String, newPassword: String, completionHandler: @ escaping (Error?) -> Void) {
        guard let user = Auth.auth().currentUser else {
            Log.log(level: .ERROR, "Invalid current user")
            completionHandler(NSError(domain: "", code: 1, userInfo: [ NSLocalizedDescriptionKey: "User not authenticated"]))
            return
        }
        let credential = EmailAuthProvider.credential(withEmail: user.email ?? "", password: oldPassword)
        user.reauthenticate(with: credential) { authDataResult, error in
            if let error = error {
                Log.log(level: .ERROR, "Error re-authenticating: \(error)")
                completionHandler(error)
            } else {
                user.updatePassword(to: newPassword) { error in
                    if let error = error {
                        Log.log(level: .ERROR, "Error updating password = \(error)")
                    }
                    completionHandler(error)
                }
            }
        }
    }


}
