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

extension FireB {

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
                        prepareNotification(id: String(order.number), title: "ORDER", subtitle: String(order.number), body: "Your order has been " + order.status.rawValue, attachmentFile: "roomOrder")
                    }
                } catch {
                    Log.log(level: .ERROR, "Failed to decode JSON")
                    Log.log(level: .ERROR, snapshot.debugDescription)
                    Log.log(level: .ERROR, error.localizedDescription)
                }
            }
        })
    }

    func getGuests(hotelID: String, completionHandler: @ escaping ([(String, GuestInfo)]) -> Void) {
        let guestsRef = Database.database().reference().child("hotels").child(hotelID).child("users")
        guestsRef.getData { (error, snapshot) in
            if let error = error {
                Log.log("Error getting data \(error)")
            } else {
                Log.log(level: .INFO, "Got data \(snapshot.value!)")
                let data: [(String, GuestInfo)] = self.decodeSnapshot(snapshot: snapshot)
                completionHandler(data)
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

//        guard let key = ref.child("posts").childByAutoId().key else { return }
//        let post = ["uid": userID,
//                    "author": username,
//                    "title": title,
//                    "body": body]
//        let childUpdates = ["/posts/\(key)": post,
//                            "/user-posts/\(userID)/\(key)/": post]
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
