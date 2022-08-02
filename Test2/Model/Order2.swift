//
//  Order2.swift
//  Test2
//
//  Created by maciulek on 20/07/2022.
//

import Foundation
/*
protocol OrderItem: Codable {
    var title: String { get }
    var comment: String { get }
    var quantity: Int? { get }
    var price: Double? { get }
}

struct RoomOrderItem: OrderItem {
    private var item: RoomItem

    var title: String { item.name }
    var comment: String = ""
    var quantity: Int? = 1
    var price: Double? = nil
}

struct FoodOrderItem: OrderItem {
    var item: MenuItem
    var title: String { item.title }
    var _quantity: Int
    var quantity: Int? { _quantity }
    var comment: String
    var price: Double? { item.price * Double(_quantity) }
    var choiceIndex: Int?
    var addons: [Int]?
}

struct ServiceOrderItem: OrderItem {
    var title: String
    var comment: String = ""
    var quantity: Int? = nil
    var price: Double? = nil
}
*/
 
 
/*
struct AnyOrderItem: Codable {
    var orderItem: OrderItem

    init(_ orderItem: OrderItem) {
        self.orderItem = orderItem
    }

    private enum CodingKeys : CodingKey {
        case type
        case orderItem
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let type = Order2InDB.getType(category: .RoomService)
        //try container.encode(type(of: orderItem).type, forKey: .type)
        //try container.encode(type, forKey: .type)
        try orderItem.encode(to: encoder)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let type = try container.decode(ItemType.self, forKey: .type)
        self.item = try type.metatype.init(from: decoder)
    }

}
*/
/*
enum OrderCategory: Codable, Hashable, CaseIterable {
    case RoomService
    case Maintenance
    case Cleaning
    case LuggageService
    case Buggy
    case RoomItems
    case None
    func toString() -> String {
        switch self {
        case .RoomService: return .roomService
        case .Maintenance: return .maintenance
        case .Cleaning: return .cleaning
        case .LuggageService: return .luggageService
        case .Buggy: return .buggy
        case .RoomItems: return .roomItems
        case .None: return ""
        }
    }
}

enum OrderStatus: Codable {
    case INIT
    case CREATED(at: Date, by: String)
    case CONFIRMED(at: Date, by: String)
    case DELIVERED(at: Date, by: String)
    case CANCELED(at: Date, by: String)
    func toString() -> String {
        switch self {
        case .INIT: return ""
        case .CREATED: return .created
        case .CONFIRMED: return .confirmed
        case .DELIVERED: return .delivered
        case .CANCELED: return .canceled
        }
    }
    var done: (at: Date, by: String) {
        switch self {
        case .INIT: return (Date(), "")
        case let .CREATED(at, by):
            return (at, by)
        case let .CONFIRMED(at, by):
            return (at, by)
        case let .DELIVERED(at, by):
            return (at, by)
        case let .CANCELED(at, by):
            return (at, by)
        }
    }
}
*/
/*
protocol OrderProtocol: Codable {
    var id: String { get }
    var number: Int { get }
    var roomNumber: Int { get }
    var category: OrderCategory { get }
    var status: OrderStatus { get }
    var items: [OrderItemProtocol] { get }
    var totalNrOfItemsInOrder: Int { get }
    var totalAmountInOrder: Double? { get }
    func setStatus(status: OrderStatus)
}
*/
/*
struct Order2 {
    var items: [OrderItem] { [] }
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
            for item in items {
                if let p = item.price, let q = item.quantity {
                    total += Double(q) * p
                }
            }
            return nil
        } else {
            return nil
        }
    }
    mutating func setStatus(status: OrderStatus) {
        statusHistory.append(status)
    }
}



struct Order2InDB: Codable {
    var id: String? = nil
    var number: Int = 0
    var roomNumber: Int = 0
    var statusHistory: [OrderStatus]?
    var comment: String?
    var category: OrderCategory = .None
    var roomOrderItems: [RoomOrderItem]? = nil
    var foodOrderItems: [FoodOrderItem]? = nil
    var serviceOrderItems: [ServiceOrderItem]? = nil
}
*/
/*
    //static func getType(category: OrderCategory) -> OrderItem.Type {
    static func getType(category: OrderCategory) -> OrderItem.Type {
        switch (category) {
        case .Buggy, .Cleaning, .LuggageService, .Maintenance : return ServiceOrderItem.self
        case .RoomService: return FoodOrderItem.self
        case .RoomItems: return RoomOrderItem.self
        default: return OrderItem.self as! OrderItem.Type
        }
    }

    enum CodingKeys: CodingKey {
      case id, number, roomNumber, statusHistory, comment, category, items
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String?.self, forKey: .id)
        number = try container.decode(Int.self, forKey: .number)
        roomNumber = try container.decode(Int.self, forKey: .roomNumber)
        statusHistory = try container.decode([OrderStatus]?.self, forKey: .statusHistory)
        comment = try container.decode(String?.self, forKey: .comment)
        category = try container.decode(OrderCategory.self, forKey: .category)

        let t = Order2InDB.getType(category: category)
        let tt = type(of: [t])
        items = try container.decode(tt, forKey: .items)
        
        //let orderItemType = Order2InDB.getArrayType(category: category)
        let orderItemDecoder = try container.superDecoder(forKey: .items)
        items = try tt.init(from: orderItemDecoder)

        items = try orderItemType.init(from: orderItemDecoder)
        //let orderItemDecoder = try container.nestedUnkeyedContainer(forKey: .items)
        //items = try [orderItemType].init(from: orderItemDecoder as! Decoder)
        //items = try [orderItemType]?.init(from: orderItemDecoder)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(number, forKey: .number)
        try container.encode(roomNumber, forKey: .roomNumber)
        try container.encode(statusHistory, forKey: .statusHistory)
        try container.encode(comment, forKey: .comment)
        try container.encode(category, forKey: .category)
        let orderItemsContainer = container.superEncoder(forKey: .items)
        try items.encode(to: orderItemsContainer)
    }
*/

