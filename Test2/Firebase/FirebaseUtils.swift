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
                    let orderFromDB: Order6InDB = try decoder.decode(Order6InDB.self, from: data!)
                    let order = Order6(id: snapshot.key, orderInDb: orderFromDB)
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

    func updateOrderStatus(orderId: String, newStatus: OrderStatus, confirmedBy: String? = nil, deliveredBy: String? = nil, canceledBy: String? = nil) {
        let orderRef = ORDERS_DB_REF.child("/\(orderId)")
        var key = ""
        switch newStatus {
        case .CREATED: key = "created"
        case .CANCELED: key = "canceled"
        case .CONFIRMED: key = "confirmed"
        case .DELIVERED: key = "delivered"
        case .INIT: key = "init"
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

    func updateOrderStatus(order: Order6) {
        let orderRef = ORDERS_DB_REF.child("/\(order.id)")
        if let json = try? JSONEncoder().encode(order.statusHistory), let dictionary = try? JSONSerialization.jsonObject(with: json) {
            let childUpdates:[String : Any] = ["statusHistory": dictionary]
            orderRef.updateChildValues(childUpdates) { (error, dbref) in
                if let error = error {
                    Log.log(level: .ERROR, "Error updating order status \(error.localizedDescription)")
                }
            }
        }
    }

    func updateLike(group: String, userID: String, itemKey: String, add: Bool) {
        let dbRef = LIKES_DB_REF
        let childUpdates:[String : Any] = [
            "/global/\(group)/\(itemKey)/count" : ServerValue.increment(add ? 1 : -1),
            "/perUser/\(userID)/\(group)/\(itemKey)" : (add ? true : false)
        ]

        dbRef.updateChildValues(childUpdates) { (error, dbref) in
            if let error = error {
                Log.log(level: .ERROR, "Error updating likes \(error.localizedDescription)")
            }
        }
    }

    func updateReview(group: String, id: String, review: Review) {
        var updatedReview = review
        updatedReview.rating += 1  // 0-based in the app, 1-based in the DB
        _ = dbProxy.addRecord(key: nil, subNode: "\(group)/\(id)", record: updatedReview) { _,_ in }

        let dbRef = REVIEWS_DB_REF.child("totals/\(group)/\(id)/\(String(format:"%02d", review.rating))")
        dbRef.setValue(ServerValue.increment(1))
        //dbRef.setValue(ServerValue.increment(1), andPriority: updatedReview.rating)
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
        if !phoneUser.isStaff, let roomNumber = phoneUser.roomNumber {
            CHATROOMS_DB_REF.child(chatRoomID).child("roomNumber").setValue(roomNumber) { (error, ref) -> Void in
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

    func writeReview(group: String, id: String, rating: Int, review: String, completionHandler: @ escaping () -> Void) {
        let updates = [
            "/global/\(group)/\(id)": ["rating": rating, "review": review],
            "/perUser/\(phoneUser.id)/\(group)/\(id)": ["rating": rating, "review": review]
        ] as [String : Any]
        REVIEWS_DB_REF.updateChildValues(updates)  { (error, dbref) in
            if let error = error {
                Log.log(level: .ERROR, "Error updating review\n\(error.localizedDescription)")
            } else {
                completionHandler()
            }
        }
    }

    func writeMenuList(restaurantId: String, menuList: [String], completionHandler: @ escaping () -> Void) {
        let updates = [
            "menus": menuList,
        ] as [String : Any]
        RESTAURANTS_DB_REF.child(restaurantId).updateChildValues(updates)  { (error, dbref) in
            if let error = error {
                Log.log(level: .ERROR, "Error writing menu list\n\(error.localizedDescription)")
            } else {
                completionHandler()
            }
        }
    }
}


extension FirebaseDatabase {
    func getRoomList(hotelId: String, completionHandler: @ escaping ([Int]) -> Void) {
        var roomList: [Int] = []
        let dbRef:DatabaseQuery = ROOT_DB_REF.child("v2").child("hotels").child(hotelId).child("config").child("rooms")
        dbRef.getData() { error, snapshot in
            if let rooms = snapshot.value as? [String:Bool] {
                roomList = rooms.keys.compactMap({Int($0)}).sorted()
                completionHandler(roomList)
            } else {
                Log.log(level: .ERROR, error.debugDescription)
                completionHandler([])
            }
        }
    }

    func getHotelList(completionHandler: @ escaping ([String:String]) -> Void) {
        var hotelList: [String:String] = [:]
        let dbRef:DatabaseQuery = ROOT_DB_REF.child("v2").child("config").child("hotels")
        dbRef.getData() { error, snapshot in
            if let hotels = snapshot.value as? [String:String] {
                hotelList = hotels
            }
            completionHandler(hotelList)
        }
    }
}
