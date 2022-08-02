//
//  Order3.swift
//  Test2
//
//  Created by maciulek on 24/07/2022.
//

import Foundation

protocol OrderItem: Codable {
//    var title: String { get }
//    var quantity: Int { get }
//    var totalPrice: Double? { get }
}


struct Order2 {
    var items: [OrderItem] = []
    var id: String = ""
    var number: Int = 0
    var roomNumber: Int = 0
    var category: OrderCategory = .None
    var statusHistory: [OrderStatus] = []
    var status: OrderStatus { statusHistory.last ?? .INIT }
    var comment: String = ""
    var totalAmountInOrder: Double? {
        if category == .RoomService {
            var total = 0.0
            //for item in items { total += item.totalPrice ?? 0 }
            return total
        } else {
            return nil
        }
    }
    mutating func setStatus(status: OrderStatus) {
        statusHistory.append(status)
    }
}



struct Order2InDB: Codable {
    private (set) var id: String?
    private (set) var number: Int
    private (set) var roomNumber: Int
    private (set) var statusHistory: [OrderStatus]?
    private (set) var comment: String?
    private (set) var category: OrderCategory
    private (set) var roomOrderItems: [RoomOrderItem]? = nil
    private (set) var foodOrderItems: [FoodOrderItem]? = nil
    //private (set) var serviceOrderItems: [ServiceOrderItem]? = nil
    private (set) var buggyOrderItems: [BuggyOrderItem]? = nil
    init(order: Order2) {
        number = order.number
        roomNumber = order.roomNumber
        statusHistory = order.statusHistory
        comment = order.comment
        category = order.category
        switch category {
        case .RoomService:
            foodOrderItems = []
            for i in order.items {
                if let foodItem = i as? FoodOrderItem {
                    foodOrderItems?.append(foodItem)
                }
            }
        case .Maintenance, .Cleaning, .Luggage: break
//        case .Maintenance, .Cleaning, .Luggage:
//            serviceOrderItems = []
//            for i in order.items {
//                if let serviceItem = i as? ServiceOrderItem {
//                    serviceOrderItems?.append(serviceItem)
//                }
//            }
        case .Buggy:
            buggyOrderItems = []
            for i in order.items {
                if let buggyItem = i as? BuggyOrderItem {
                    buggyOrderItems?.append(buggyItem)
                }
            }
        case .RoomItems:
            roomOrderItems = []
            for i in order.items {
                if let roomItem = i as? RoomOrderItem {
                    roomOrderItems?.append(roomItem)
                }
            }
        case .None: break
        }
    }
}

extension Order2 {
    init(id: String, orderInDb: Order2InDB) {
        self.id = id
        number = orderInDb.number
        roomNumber = orderInDb.roomNumber
        statusHistory = orderInDb.statusHistory ?? []
        comment = orderInDb.comment ?? ""
        category = orderInDb.category
        switch category {
        case .RoomService:
            if let itemsInDb = orderInDb.foodOrderItems {
                for i in itemsInDb {
                    //items.append(i)
                }
            }
//        case .Maintenance, .Cleaning, .Luggage:
//            if let itemsInDb = orderInDb.serviceOrderItems {
//                for i in itemsInDb {
//                    items.append(i)
//                }
//            }
        case .Buggy:
            if let itemsInDb = orderInDb.buggyOrderItems {
                for i in itemsInDb {
                    //items.append(i)
                }
            }
        case .RoomItems:
            if let itemsInDb = orderInDb.roomOrderItems {
                for i in itemsInDb {
                    //items.append(i)
                }
            }
        default: break
        }
    }
}
