//
//  FirebaseDatabase.swift
//  Test2
//
//  Created by maciulek on 15/04/2022.
//

import Foundation
import Firebase
import FirebaseDatabase

final class FirebaseDatabase: DBProxy {
    static let shared: FirebaseDatabase = FirebaseDatabase()

    var isConnected: Bool = false
    var serverTimeOffet:Double = 0.0
    
    struct SubscriptionHandle {
        var dbRef: DatabaseQuery
        var handle: UInt
    }

    var ROOT_DB_REF: DatabaseReference {
        return Firebase.shared.database.reference()
    }

    var ROOTVER_DB_REF: DatabaseReference {
        return ROOT_DB_REF.child("v2")
    }

    var BASE_DB_REF: DatabaseReference          {
        if hotel.id != "" {
            return ROOTVER_DB_REF.child("hotels").child(hotel.id)
        } else {
            return ROOTVER_DB_REF.child("hotels")
        }
    }

    var DBINFO_DB_REF: DatabaseReference        { ROOT_DB_REF.child(".info") }      // internal Firebase status

    var HOTEL_DB_REF: DatabaseReference         { BASE_DB_REF }
    var CONFIG_DB_REF: DatabaseReference        { BASE_DB_REF }

    var CONTENT_DB_REF: DatabaseReference       { BASE_DB_REF.child("content") }
    var NEWS_DB_REF: DatabaseReference          { CONTENT_DB_REF.child("news") }
    var ACTIVITIES_DB_REF: DatabaseReference    { CONTENT_DB_REF.child("activities") }
    var RESTAURANTS_DB_REF: DatabaseReference   { CONTENT_DB_REF.child("restaurants") }
    var INFO_DB_REF: DatabaseReference          { CONTENT_DB_REF.child("info") }
    var MENUS_DB_REF: DatabaseReference         { CONTENT_DB_REF.child("menus") }
    var OFFERGROUPS_DB_REF: DatabaseReference   { CONTENT_DB_REF.child("offerGroups") }
    var OFFERS_DB_REF: DatabaseReference        { CONTENT_DB_REF.child("offers") }
    var TRANSLATIONS_DB_REF: DatabaseReference  { CONTENT_DB_REF.child("translations") }

    var FEEDBACK_DB_REF: DatabaseReference      { BASE_DB_REF.child("feedback") }
    var REVIEWS_DB_REF: DatabaseReference       { FEEDBACK_DB_REF.child("reviews") }
    var LIKES_DB_REF: DatabaseReference         { BASE_DB_REF.child("likes") }
    var LIKESGLOBAL_DB_REF: DatabaseReference   { LIKES_DB_REF.child("global") }
    var LIKESPERUSER_DB_REF: DatabaseReference  { LIKES_DB_REF.child("perUser") }

    var CHAT_DB_REF: DatabaseReference          { BASE_DB_REF.child("chat") }
    var CHATROOMS_DB_REF: DatabaseReference     { CHAT_DB_REF.child("chatRooms") }
    var CHATS_DB_REF: DatabaseReference         { CHAT_DB_REF.child("chats") }

    var GUESTS_DB_REF: DatabaseReference        { BASE_DB_REF.child("guests") }
    var FACILITIES_DB_REF: DatabaseReference    { BASE_DB_REF.child("facilities") }
    var ORDERS_DB_REF: DatabaseReference        { BASE_DB_REF.child("orders") }

    var PHONES_DB_REF: DatabaseReference        { BASE_DB_REF.child("phones") }
    var LOGS_DB_REF: DatabaseReference          { BASE_DB_REF.child("logs") }

    var observed: Set<DatabaseQuery> = []

    func getDBRef<T>(type: T.Type, subNode: String? = nil) -> DatabaseReference? {
        switch type {
            case is HotelConfigInDB.Type:
                return CONFIG_DB_REF
            case is InfoItem.Type:
                return INFO_DB_REF
            case is NewsPost.Type:
                return NEWS_DB_REF
            case is DailyActivities.Type:
                if let child = subNode { return ACTIVITIES_DB_REF.child(child) }
                else { return ACTIVITIES_DB_REF }
            case is Activity.Type:
                if let child = subNode { return ACTIVITIES_DB_REF.child(child) }
                else { return ACTIVITIES_DB_REF }
//            case is OrderInDB.Type:
//                return ORDERS_DB_REF
            case is Order6InDB.Type:
                return ORDERS_DB_REF
//            case is Order4InDB<ServiceOrderItem>.Type:
//                return ORDERS_DB_REF
//            case is Order4InDB<RoomOrderItem>.Type:
//                return ORDERS_DB_REF
//            case is Order4InDB<FoodOrderItem>.Type:
//                return ORDERS_DB_REF
            case is OfferGroup.Type:
                return OFFERGROUPS_DB_REF
            case is Offer.Type:
                return OFFERS_DB_REF
            case is RestaurantInDB.Type:
                return RESTAURANTS_DB_REF
            case is Facility.Type:
                return FACILITIES_DB_REF
            case is MenuInDB.Type:
                return MENUS_DB_REF
            case is ChatRoomInDB.Type:
                return CHATROOMS_DB_REF
            case is ChatMessage.Type:
                if let child = subNode { return CHATS_DB_REF.child(child) }
                else { return CHATS_DB_REF }
            case is GuestInDB.Type:
                return GUESTS_DB_REF
            case is LikesPerUserInDB.Type:
                if let child = subNode { return LIKESPERUSER_DB_REF.child(child) }
                else { return LIKESPERUSER_DB_REF }
            case is Review.Type:
                if let child = subNode { return REVIEWS_DB_REF.child(child) }
                else { return REVIEWS_DB_REF }
            case is LikesInDB.Type:
                if let child = subNode { return LIKESGLOBAL_DB_REF.child(child) }
                else { return LIKESGLOBAL_DB_REF }
            case is Translations.Type:
                if let child = subNode { return TRANSLATIONS_DB_REF.child(child) }
                else { return TRANSLATIONS_DB_REF }
            case is LogInDB.Type:
                if let child = subNode { return LOGS_DB_REF.child(child) }
                else { return LOGS_DB_REF }
            default:
                return nil
        }
    }

    func getQuery<T>(type: T.Type, subNode: String? = nil, parameter:QueryParameter? = nil) -> DatabaseQuery? {
        let dbRef = getDBRef(type: type.self, subNode: subNode)
        let errStr = "Invalid parameter in getQuery for \(T.Type.self): \(String(describing: parameter))"
        switch type {
            case is HotelConfigInDB.Type:
                return dbRef?.queryOrderedByKey().queryEqual(toValue: "config")
//            case is HotelInfo.Type:
//                return dbRef?.queryOrderedByKey().queryEqual(toValue: "config")
            case is GuestInfo.Type:
                guard case .GuestInfo(let guestId) = parameter else { Log.log(errStr); return nil }
                return dbRef?.queryOrderedByKey().queryEqual(toValue: guestId)
            case is GuestInDB.Type:
                guard case .GuestInDb(let guestId) = parameter else { Log.log(errStr); return nil }
                return dbRef?.queryOrderedByKey().queryEqual(toValue: guestId)
        case is Order6InDB.Type://, is Order4InDB<ServiceOrderItem>.Type, is Order4<RoomOrderItem>.Type, is Order4<FoodOrderItem>.Type:
                switch parameter {
                    case .OrderByRoom(let roomNumber):
                        return dbRef?.queryOrdered(byChild: "roomNumber").queryEqual(toValue: roomNumber)
                    case .OrderByCategory(let category):
                        return dbRef?.queryOrdered(byChild: "description").queryEqual(toValue: category.rawValue)
                    case .OrderByAssignment(let assignedTo):
                        return dbRef?.queryOrdered(byChild: "assignedTo").queryEqual(toValue: assignedTo)
                    default:
                        return dbRef?.queryOrderedByKey()
                }
            case is ChatRoomInDB.Type:
                switch parameter {
                    case .AssignedTo(let id):
                        return dbRef?.queryOrdered(byChild: "assignedTo").queryEqual(toValue: id)
                    case .ChatRoom(let id):
                        return dbRef?.queryOrderedByKey().queryEqual(toValue: id)
                    default:
                        return dbRef
                }
            case is Review.Type:
                guard case .Review(let id) = parameter else { return dbRef }
                return dbRef?.queryOrderedByKey().queryEqual(toValue: id)
                //return dbRef?.queryOrdered(byChild: id).queryEqual(toValue: id)
            default:
                return dbRef
        }
    }

    func addRecord<T: Encodable>(key:String? = nil, subNode: String? = nil, record: T, completionHandler: @ escaping (String?, T?) -> Void) -> String? {

        var errString:String? = nil
        if let jsonData = try? JSONEncoder().encode(record) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

            let dbRefForType = getDBRef(type: T.self, subNode: subNode)
            var dbRef = dbRefForType?.childByAutoId()
            if let key = key { dbRef = dbRefForType?.child(key) }

            if let dbRef = dbRef {
                dbRef.setValue(dictionary) { error, dbRef in
                    if let err = error {
                        Log.log(level: .ERROR, "error uploading key \(String(describing: key)) for record \(T.self) - \(err.localizedDescription)",
                                logInDb: T.Type.self != LogInDB.self)
                        completionHandler(nil, nil)
                    } else {
                        if T.Type.self != LogInDB.Type.self {   // do not log records added by Log itself
                            Log.log(level: .INFO, "Record with key \(String(describing: key)) added to \(dbRef.url)")
                        }
                        completionHandler(dbRef.key, record)
                    }
                }
            } else {
                errString = "dbRef nil for type \(T.self) and key \(String(describing: key))"
            }
        }
        else {
            errString = "JSONEncoder failed"
        }
        if let errStr = errString { Log.log(level: .ERROR, errStr) }
        return errString
    }

    func removeRecord<T: Encodable>(key:String, subNode: String? = nil, record: T, completionHandler: @ escaping (T?) -> Void) -> String? {
        let dbRefForType = getDBRef(type: T.self, subNode: subNode)
        let dbRef = dbRefForType?.child(key)

        var errString:String? = nil
        if let dbRef = dbRef {
            dbRef.removeValue() { error, dbRef in
                if let err = error {
                    Log.log("error removing key \(String(describing: key))")
                    Log.log(level: .ERROR, "\(err.localizedDescription)")
                    completionHandler(nil)
                } else {
                    Log.log(level: .INFO, "Record with key \(String(describing: key)) removed")
                    completionHandler(record)
                }
            }
        } else {
            errString = "dbRef nil for type \(T.self) and key \(String(describing: key))"
        }
        return errString
    }

    func removeRecord(path:String, key:String, completionHandler: @ escaping (Error?) -> Void) {
        let dbRef = ROOTVER_DB_REF.child(path).child(key)
        dbRef.removeValue() { error, dbRef in
            if let err = error {
                    Log.log("Error removing key \(String(describing: key)) from \(dbRef)")
                    Log.log(level: .ERROR, "\(err.localizedDescription)")
                    completionHandler(err)
            } else {
                Log.log(level: .INFO, "Key \(key) removed from \(dbRef)")
                completionHandler(nil)
            }
        }
    }

    func subscribe<T: Codable>(for operation: QueryOperation, subNode: String? = nil, parameter: QueryParameter? = nil, completionHandler: @ escaping (String, T) -> Void) -> Any? {
        guard let query = getQuery(type: T.self, subNode: subNode, parameter: parameter) else {
            Log.log(level: .ERROR, "Invalid subscription: \(operation) \(String(describing: subNode)) \(String(describing: parameter))")
            return nil
        }
        Log.log(level: .DEBUG, "observing for \(operation) " + query.description)
        observed.insert(query)
        let det:DataEventType
        switch operation {
            case .NEW: det = .childAdded
            case .DELETE: det = .childRemoved
            case .UPDATE: det = .childChanged
        }
        let handle = query.observe(det, with: { (snapshot) in
            guard JSONSerialization.isValidJSONObject(snapshot.value!) else {
                Log.log("Invalid JSON: \(snapshot.value!) in query: \(query)")
                return
            }
            let data = try? JSONSerialization.data(withJSONObject: snapshot.value!)
            do {
                let object = try JSONDecoder().decode(T.self, from: data!)
                completionHandler(snapshot.key, object)
            } catch {
                Log.log(level: .ERROR, "Failed to decode JSON for query \(query) : \(data.debugDescription)\n \(error)")
            }
        })
        return SubscriptionHandle(dbRef: query, handle: handle)
    }

    func subscribeForUpdates<T: Codable>(subNode: String? = nil, start timestamp: Int? = nil, limit: UInt? = nil, parameter: QueryParameter? = nil, completionHandler: @ escaping ([String:T]) -> Void) -> Any? {

        guard let query = getQuery(type: T.self, subNode: subNode, parameter: parameter) else { return nil }
        Log.log(level: .DEBUG, "Observing \(query.description)")
        observed.insert(query)
        let handle = query.observe(.value, with: { (snapshot) in
            var objects: [String:T] = [:]
            Log.log(level: .DEBUG, "Adding \(snapshot.children.allObjects.count) new objects of type \(T.self)")
            for child in snapshot.children {
                guard let item = child as? DataSnapshot, let value = item.value, JSONSerialization.isValidJSONObject(value) else {
                    Log.log(level:.ERROR, "Invalid JSON: \(child) in query: \(query)")
                    return
                }
                let key = item.key
                if let data = try? JSONSerialization.data(withJSONObject: value) {
                    do {
                        let object = try JSONDecoder().decode(T.self, from: data)
                        objects[key] = object
                    } catch {
                        Log.log(level: .ERROR, "Failed to decode JSON for type \(T.self): \(item) - \(error)")
                    }
                } else {
                    Log.log(level: .ERROR, "Serialization failed for \(item)")
                }
            }
            Log.log(level: .DEBUG, "\(objects.count) new objects of type \(T.self) added")
            completionHandler(objects)
        })
        return SubscriptionHandle(dbRef: query, handle: handle)
    }

    func subscribeForUpdates(path: String, completionHandler: @ escaping ([String:Any]) -> Void) -> Any? {
        let dbRef = BASE_DB_REF.child(path)
        Log.log(level: .DEBUG, "Observing \(dbRef.description)")
        observed.insert(dbRef)
        let handle =  dbRef.observe(.value, with: { (snapshot) in
            var objects: [String:Any] = [:]
            Log.log(level: .DEBUG, "Adding \(snapshot.children.allObjects.count) new objects")
            for child in snapshot.children {
                guard let item = child as? DataSnapshot, let value = item.value, JSONSerialization.isValidJSONObject(value) else {
                    Log.log(level:.ERROR, "Invalid JSON: \(child) in query: \(dbRef)")
                    return
                }
                let key = item.key
                objects[key] = value
            }
            Log.log(level: .DEBUG, "\(objects.count) new objects of type added")
            completionHandler(objects)
        })
        return SubscriptionHandle(dbRef: dbRef, handle: handle)
    }

    func unsubscribe<T: Codable>(t: T.Type, subNode: String? = nil, parameter: QueryParameter? = nil) {
        guard let query = getQuery(type: T.self, subNode: subNode, parameter: parameter) else { return }
        query.removeAllObservers()
    }

    func unsubscribe(from handle: Any?) {
        if let handle = handle as? SubscriptionHandle {
            handle.dbRef.removeObserver(withHandle: handle.handle)
        }
    }

    func removeAllObservers() {
        for query in observed {
            query.removeAllObservers()
        }
        observed.removeAll()
    }
}
