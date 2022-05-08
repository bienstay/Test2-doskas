//
//  DBProxy.swift
//  Test2
//
//  Created by maciulek on 17/03/2022.
//

import Foundation
import UIKit

enum QueryParameter {
    case OrderInDB(roomNumber: Int)
    case ChatRoom(id: String)
    case AssignedTo(id: String)
    case ChatUser(id: String)
    case GuestInfo(id: String)
    case GuestInDb(id: String)
}

protocol DBProxy {
    
    func addRecord<T: Encodable>(key:String?, subNode: String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String?
    func removeRecord<T: Encodable>(key:String, subNode: String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String?
    @discardableResult
    func subscribeForUpdates<T: Codable>(subNode: String?, start timestamp: Int?, limit: UInt?, parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)], String?) -> Void) -> NSObject?
    func unsubscribe(handle: NSObject?)
    func unsubscribe<T>(t: T.Type, subNode: String?)
    func removeAllObservers()

    func subscribeForNew<T: Codable>(subNode: String?, parameter: QueryParameter?, completionHandler: @ escaping (String, T) -> Void)
    func subscribeForDeleted<T: Codable>(subNode: String?, parameter: QueryParameter?, completionHandler: @ escaping (String, T) -> Void)
    func subscribeForModified<T: Codable>(subNode: String?, parameter: QueryParameter?, completionHandler: @ escaping (String, T) -> Void)

    func observeOrderChanges()
    func getHotels(completionHandler: @ escaping ([String:String]) -> Void)
    func getGuests(hotelID: String, index: Int, completionHandler: @ escaping (Int, [(String, GuestInfo)]) -> Void)
    func updateOrderStatus(orderId: String, newStatus: Order.Status, confirmedBy: String?, deliveredBy: String?, canceledBy: String?)
    func updateLike(group: String, userID: String, itemKey: String, add: Bool)

    func translate(textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void)
    func translateChat(chatRoom: String, chatID: String, textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void)
    func markChatAsRead(chatRoom: String, chatID: String)
    //func addHotelToConfig(hotelId: String, hotelName: String)
    func updatePhoneData(guestId: String, phoneID: String, phoneLang: String)

    func updateGuest(hotelId: String, guestId: String, guestData: GuestInDB, completionHandler: @ escaping () -> Void)
    func log(level: Log.LogLevel, s: String)

    //func getUsers(completionHandler: @ escaping ([[String:String]]) -> Void)
    func getUsers(hotelName: String, completionHandler: @ escaping ([[String:String]]) -> Void)
    func assignChat(chatRoom: String, to user: String)
    func writeChat(chatRoomID: String, message m: ChatMessage)
    
    var isConnected: Bool { get }
}

// extensions are needed as a workaround to no default parameters in protocols
extension DBProxy {
    func addRecord<T: Encodable>(key:String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String? {
        return addRecord(key:key, subNode: nil, record: record, completionHandler: completionHandler)
    }
    func addRecord<T: Encodable>(record: T, completionHandler: @ escaping (T?) -> Void) -> String? {
        return addRecord(key:nil, subNode: nil, record: record, completionHandler: completionHandler)
    }
    func removeRecord<T: Encodable>(key:String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String? {
        return addRecord(key:key, subNode: nil, record: record, completionHandler: completionHandler)
    }
    func removeRecord<T: Encodable>(record: T, completionHandler: @ escaping (T?) -> Void) -> String? {
        return addRecord(key:nil, subNode: nil, record: record, completionHandler: completionHandler)
    }
    @discardableResult
    func subscribeForUpdates<T: Codable>(subNode: String?, parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)], String?) -> Void) -> NSObject? {
        return subscribeForUpdates(subNode: subNode, start: nil, limit: nil, parameter: parameter, completionHandler: completionHandler)
    }
    @discardableResult
    func subscribeForUpdates<T: Codable>(parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)], String?) -> Void) -> NSObject? {
        return subscribeForUpdates(subNode: nil, parameter: parameter, completionHandler: completionHandler)
    }
    @discardableResult
    func subscribeForUpdates<T: Codable>(completionHandler: @ escaping ([(String, T)], String?) -> Void) -> NSObject? {
        return subscribeForUpdates(subNode: nil, parameter: nil, completionHandler: completionHandler)
    }
}

extension DBProxy {
    func updateOrderStatus(orderId: String, newStatus: Order.Status, confirmedBy: String?) {
        updateOrderStatus(orderId: orderId, newStatus: newStatus, confirmedBy: confirmedBy, deliveredBy: nil, canceledBy: nil)
    }
    func updateOrderStatus(orderId: String, newStatus: Order.Status, deliveredBy: String?) {
        updateOrderStatus(orderId: orderId, newStatus: newStatus, confirmedBy: nil, deliveredBy: deliveredBy, canceledBy: nil)
    }
    func updateOrderStatus(orderId: String, newStatus: Order.Status, canceledBy: String?) {
        updateOrderStatus(orderId: orderId, newStatus: newStatus, confirmedBy: nil, deliveredBy: nil, canceledBy: canceledBy)
    }
}

/*
extension DBProxy {
    func uploadImage(image: UIImage, forLocation: PhotoLocation, completionHandler: @escaping (String) -> Void) {
        uploadImage(image: image, forLocation: forLocation, imageName: nil, completionHandler: completionHandler)
    }
}
*/
