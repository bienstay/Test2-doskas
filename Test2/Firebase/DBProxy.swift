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
    case ChatUser(id: String)
    case GuestInfo(id: String)
    case GuestInDb(id: String)
}

enum PhotoLocation {
    case BASE
    case NEWS
    case ACTIVITIES
    case RESTAURANTS
}

protocol DBProxy {
    
    func addRecord<T: Encodable>(key:String?, subNode: String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String?
    func removeRecord<T: Encodable>(key:String, subNode: String?, record: T, completionHandler: @ escaping (T?) -> Void) -> String?
    func subscribeForUpdates<T: Codable>(subNode: String?, start timestamp: Int?, limit: UInt?, parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)]) -> Void)
    func removeAllObservers()

    func observeOrderChanges()
    func getHotels(completionHandler: @ escaping ([String:String]) -> Void)
    func getGuests(hotelID: String, index: Int, completionHandler: @ escaping (Int, [(String, GuestInfo)]) -> Void)
    func updateOrderStatus(orderId: String, newStatus: Order.Status, confirmedBy: String?, deliveredBy: String?, canceledBy: String?)
    func updateLike(node: String, key: String, user: String, add: Bool)
    
    func translate(textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void)
    func translateChat(chatRoom: String, chatID: String, textToTranslate: String, targetLanguage: String, completionHandler: @ escaping (String?) -> Void)
    func markChatAsRead(chatRoom: String, chatID: String)
    func addHotelToConfig(hotelId: String, hotelName: String)
    func updatePhoneData(guestId: String, phoneID: String, phoneLang: String)

    func uploadImage(image: UIImage, forLocation: PhotoLocation, imageName: String?, completionHandler: @escaping (String) -> Void)
    
    func updateGuest(guestId: String, guestData: GuestInDB)
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
    func subscribeForUpdates<T: Codable>(subNode: String?, parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)]) -> Void) {
        subscribeForUpdates(subNode: subNode, start: nil, limit: nil, parameter: parameter, completionHandler: completionHandler)
    }
    func subscribeForUpdates<T: Codable>(parameter: QueryParameter?, completionHandler: @ escaping ([(String, T)]) -> Void) {
        subscribeForUpdates(subNode: nil, parameter: parameter, completionHandler: completionHandler)
    }
    func subscribeForUpdates<T: Codable>(completionHandler: @ escaping ([(String, T)]) -> Void) {
        subscribeForUpdates(subNode: nil, parameter: nil, completionHandler: completionHandler)
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

extension DBProxy {
    func uploadImage(image: UIImage, forLocation: PhotoLocation, completionHandler: @escaping (String) -> Void) {
        uploadImage(image: image, forLocation: forLocation, imageName: nil, completionHandler: completionHandler)
    }
}
