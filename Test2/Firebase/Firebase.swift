//
//  Firebase.swift
//  Test2
//
//  Created by maciulek on 16/10/2021.
//


import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFunctions

final class FireB: DBProxy {
    static let shared: FireB = FireB()
    let useEmulator: Bool = false

    lazy var functions: Functions = Functions.functions()
    lazy var storage: Storage = Storage.storage()
    lazy var auth: Auth = Auth.auth()
    lazy var database: Database = useEmulator ? Database.database(url:"http://localhost:9000?ns=bienstay-45c85-default-rtdb") : Database.database()

    private init() { }


    func initialize() {
        database.isPersistenceEnabled = true
        if useEmulator {
            //auth.useEmulator(withHost:"localhost", port:9099)
            functions.useEmulator(withHost: "localhost", port: 5001)
            //storage.useEmulator(withHost: "localhost", port: 9199)
        }
    }

    var ROOT_DB_REF: DatabaseReference {
        //let db = useEmulator ? Database.database(url:"http://localhost:9000?ns=bienstay-45c85-default-rtdb") : Database.database()
        //return db.reference()
        return database.reference()
    }

    var BASE_DB_REF: DatabaseReference          {
        if let hotelId = hotel.id {
            return ROOT_DB_REF.child("hotels").child(hotelId)
        } else {
            return ROOT_DB_REF.child("hotels")
        }

    }

    var CONFIG_DB_REF: DatabaseReference        { ROOT_DB_REF.child("config") }
    var HOTEL_DB_REF: DatabaseReference         { BASE_DB_REF }
    var INFO_DB_REF: DatabaseReference          { BASE_DB_REF }
    var GUESTS_DB_REF: DatabaseReference        { BASE_DB_REF.child("users") }
    var NEWS_DB_REF: DatabaseReference          { BASE_DB_REF.child("news") }
    var ACTIVITIES_DB_REF: DatabaseReference    { BASE_DB_REF.child("activities") }
    var RESTAURANTS_DB_REF: DatabaseReference   { BASE_DB_REF.child("restaurants") }
    var FACILITIES_DB_REF: DatabaseReference    { BASE_DB_REF.child("facilities") }
    var MENUS_DB_REF: DatabaseReference         { BASE_DB_REF.child("menus2") }
    var ORDERS_DB_REF: DatabaseReference        { BASE_DB_REF.child("orders") }
    var OFFERGROUPS_DB_REF: DatabaseReference   { BASE_DB_REF.child("offerGroups") }
    var OFFERS_DB_REF: DatabaseReference        { BASE_DB_REF.child("offers") }
    var LIKES_DB_REF: DatabaseReference         { BASE_DB_REF.child("likes") }
    var LIKESGLOBAL_DB_REF: DatabaseReference   { LIKES_DB_REF.child("global") }
    var LIKESPERUSER_DB_REF: DatabaseReference  { LIKES_DB_REF.child("perUser") }
    var CHAT_MESSAGES_DB_REF: DatabaseReference { BASE_DB_REF.child("chats").child("messages") }
    var TRANSLATIONS_DB_REF: DatabaseReference  { BASE_DB_REF.child("translations") }

    var observed: Set<DatabaseQuery> = []

    func getDBRef<T>(type: T.Type, subNode: String? = nil) -> DatabaseReference? {
        switch type {
            case is HotelInDB.Type:
                return ROOT_DB_REF.child("hotels")
            case is HotelInfo.Type:
                return INFO_DB_REF
            case is NewsPost.Type:
                return NEWS_DB_REF
            case is DailyActivities.Type:
                if let child = subNode { return ACTIVITIES_DB_REF.child(child) }
                else { return ACTIVITIES_DB_REF }
            case is Activity.Type:
                if let child = subNode { return ACTIVITIES_DB_REF.child(child) }
                else { return ACTIVITIES_DB_REF }
            case is OrderInDB.Type:
                return ORDERS_DB_REF
            case is OfferGroup.Type:
                return OFFERGROUPS_DB_REF
            case is Offer.Type:
                return OFFERS_DB_REF
            case is Restaurant.Type:
                return RESTAURANTS_DB_REF
            case is Facility.Type:
                return FACILITIES_DB_REF
            case is Menu2.Type:
                return MENUS_DB_REF
            case is ChatMessage.Type:
                if let child = subNode { return CHAT_MESSAGES_DB_REF.child(child) }
                else {return CHAT_MESSAGES_DB_REF }
            case is GuestInfo.Type:
                return GUESTS_DB_REF
            case is LikesPerUserInDB.Type:
                if let child = subNode { return LIKESPERUSER_DB_REF.child(child) }
                else { return LIKESPERUSER_DB_REF }
            case is LikesInDB.Type:
                if let child = subNode { return LIKESGLOBAL_DB_REF.child(child) }
                else { return LIKESGLOBAL_DB_REF }
            case is Translations.Type:
                if let child = subNode { return TRANSLATIONS_DB_REF.child(child) }
                else { return TRANSLATIONS_DB_REF }
            default:
                return nil
        }
    }
/*
    enum QueryParameter {
        case OrderInDB(roomNumber: Int)
        case ChatRoom(id: String)
        case ChatUser(id: String)
        case GuestInfo(id: String)
    }
*/
    func getQuery<T>(type: T.Type, subNode: String? = nil, parameter:QueryParameter? = nil) -> DatabaseQuery? {
        let dbRef = getDBRef(type: type.self, subNode: subNode)
        let errStr = "Invalid parameter in getQuery for \(T.Type.self): \(String(describing: parameter))"
        switch type {
            case is HotelInfo.Type:
                return dbRef?.queryOrderedByKey().queryEqual(toValue: "info")
            case is GuestInfo.Type:
                guard case .GuestInfo(let guestId) = parameter else { Log.log(errStr); return nil }
                return dbRef?.queryOrderedByKey().queryEqual(toValue: guestId)
            case is OrderInDB.Type:
                guard case .OrderInDB(let roomNumber) = parameter else { Log.log(errStr); return nil }
                if roomNumber > 0 {
                    return dbRef?.queryOrdered(byChild: "roomNumber").queryEqual(toValue: roomNumber)
                } else {
                    return dbRef?.queryOrderedByKey()
                }
            case is ChatMessage.Type:
                guard case .ChatRoom(let chatRoomId) = parameter else { Log.log(errStr); return nil }
                return dbRef?.child(chatRoomId)
            default:
                return dbRef
        }
    }

    func addRecord<T: Encodable>(key:String? = nil, subNode: String? = nil, record: T, completionHandler: @ escaping (T?) -> Void) -> String? {

        var errString:String? = nil
        if let jsonData = try? JSONEncoder().encode(record) {
            let dictionary = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any]

            let dbRefForType = getDBRef(type: T.self, subNode: subNode)
            var dbRef = dbRefForType?.childByAutoId()
            if let key = key { dbRef = dbRefForType?.child(key) }

            if let dbRef = dbRef {
                dbRef.setValue(dictionary) { error, dbRef in
                    if let err = error {
                        Log.log(level: .ERROR, "error uploading key \(String(describing: key))")
                        Log.log(level: .ERROR, "\(err)")
                        completionHandler(nil)
                    } else {
                        Log.log(level: .INFO, "Record with key \(String(describing: key)) added to \(dbRef.url)")
                        completionHandler(record)
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
                    Log.log(level: .ERROR, "\(err)")
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


    func subscribeForUpdates<T: Codable>(subNode: String? = nil, start timestamp: Int? = nil, limit: UInt? = nil, parameter: QueryParameter? = nil, completionHandler: @ escaping ([(String, T)]) -> Void) {
        
        guard let query = getQuery(type: T.self, subNode: subNode, parameter: parameter) else { return }
        Log.log(level: .DEBUG, "observing " + query.description)
        observed.insert(query)
        query.observe(.value, with: { (snapshot) in
            var objects: [(String, T)] = []
            Log.log(level: .DEBUG, "adding \(snapshot.children.allObjects.count) new objects of type \(T.self)")
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let decoder = JSONDecoder()
                if JSONSerialization.isValidJSONObject(item.value!) {
                    let data = try? JSONSerialization.data(withJSONObject: item.value!)
                    do {
                        let object = try decoder.decode(T.self, from: data!)
                        objects.append((item.key, object))
                    } catch {
                        Log.log(level: .ERROR, "Failed to decode JSON for type \(T.self)")
                        Log.log(level: .ERROR, item.debugDescription)
                        Log.log(level: .ERROR, data.debugDescription)
                        Log.log(level: .ERROR, "\(error)")
                    }
                }
            }
            Log.log(level: .DEBUG, "\(objects.count) new objects of type \(T.self) added")

            completionHandler(objects)
        })
    }

    func removeAllObservers() {
        for query in observed {
            query.removeAllObservers()
        }
        observed.removeAll()
    }
    
    func decodeSnapshot<T: Codable>(snapshot: DataSnapshot) -> [(String, T)] {
        var objects: [(String, T)] = []
        Log.log(level: .DEBUG, "decoding \(snapshot.children.allObjects.count) new objects of type \(T.self)")
        for item in snapshot.children.allObjects as! [DataSnapshot] {
            let decoder = JSONDecoder()
            let data = try? JSONSerialization.data(withJSONObject: item.value!)
            do {
                let object = try decoder.decode(T.self, from: data!)
                objects.append((item.key, object))
            } catch {
                Log.log("Failed to decode JSON")
                Log.log(item.debugDescription)
                Log.log(data.debugDescription)
                Log.log(level: .ERROR, "\(error)")
            }
        }
        return objects
    }
}
