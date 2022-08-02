//
//  Order4.swift
//  Test2
//
//  Created by maciulek on 24/07/2022.
//

import Foundation

struct RoomItem: Hashable, Codable {
    enum ItemType: String, Codable, Hashable, CaseIterable {
        case Toiletries = "Toiletries"
        case BathAmenities = "Bath Amenities"
        case RoomAmenities = "Room Amenities"
        case RoomConsumables = "Room Consumables"
        case None = "None"
        func toString() -> String {
            switch self {
            case .Toiletries: return .toiletries
            case .BathAmenities: return .bathAmenities
            case .RoomAmenities: return .roomAmenities
            case .RoomConsumables: return .roomConsumables
            case .None: return ""
            }
        }
    }

    var name: String = ""
    var type: ItemType = .Toiletries
    var picture: String = ""
    var color: String = "000000"
    var maxQuantity: Int = 5
}

struct RoomOrderItem: Codable {
    private (set) var item: RoomItem
    var quantity: Int = 0
    init(item: RoomItem) { self.item = item }
}

typealias RoomOrderItemInDB = RoomOrderItem

struct ServiceOrderItem: Codable {
    var title: String
    var quantity: Int = 1
    var totalPrice: Double? = nil
}

typealias ServiceOrderItemInDB = ServiceOrderItem

struct BuggyOrderItem: Codable {
    enum LocationType: Int, Codable {
        case Room
        case GPS
        case Photo
        case Other
        func toString() -> String {
            return String(describing: self)
        }
    }
    var locationType: LocationType
    var locationData: String
}

typealias BuggyOrderItemInDB = BuggyOrderItem

struct FoodOrderItem: Codable, Equatable {
    private (set) var item: MenuItem

    var choiceIndex: Int?
    var addonCount: [Int]?
    var quantity: Int = 0
    var totalPrice: Double {
        var itemPrice = item.price
        if let choiceIndex = choiceIndex, let choices = item.choices,  choiceIndex < choices.count {
            itemPrice = choices[choiceIndex].price
        }
        var addonsPrice = 0.0
        if let addons = addonCount {
            for i in 0...addons.count - 1 {
                addonsPrice += (item.addons?[i].price ?? 0) * Double(addons[i])
            }
        }
        let total = itemPrice * Double(quantity) + addonsPrice
        return total
    }
    init(item: MenuItem) {
        self.item = item
        if let addons = item.addons {
            addonCount = [Int](repeating: 0, count: addons.count)
        }
    }
}

struct FoodOrderItemInDB: Codable {
    private (set) var item: MenuItemInDB

    var choiceIndex: Int?
    var addonCount: [Int]?
    var quantity: Int
    
    init(f: FoodOrderItem) {
        choiceIndex = f.choiceIndex
        addonCount = f.addonCount
        quantity = f.quantity
        item = MenuItemInDB(f.item)
    }
}

extension FoodOrderItem {
    init(f: FoodOrderItemInDB) {
        choiceIndex = f.choiceIndex
        addonCount = f.addonCount
        quantity = f.quantity
        item = MenuItem(f.item)
    }
}

enum OrderCategory: String, Codable, Hashable, CaseIterable {
    case RoomService = "Room Service"
    case Maintenance
    case Cleaning
    case Luggage
    case Buggy
    case RoomItems = "Room Items"
    case None
    func toString() -> String {
        switch self {
        case .RoomService: return .roomService
        case .Maintenance: return .maintenance
        case .Cleaning: return .cleaning
        case .Luggage: return .luggageService
        case .Buggy: return .buggy
        case .RoomItems: return .roomItems
        case .None: return ""
        }
    }
}

enum OrderStatus: Codable, Equatable {
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


struct Order6 {
    var foodItems: [FoodOrderItem] = []
    var roomItems: [RoomOrderItem] = []
    var buggyItem: BuggyOrderItem? = nil
    var id: String = ""
    var number: Int = 0
    var roomNumber: Int = 0
    var category: OrderCategory
    var statusHistory: [OrderStatus] = []
    var status: OrderStatus { statusHistory.last ?? .INIT }
    var isActive: Bool {
        switch status {
        case .INIT, .DELIVERED(_, _), .CANCELED(_, _): return false
        case .CREATED(_, _), .CONFIRMED(_, _): return true
        }
    }
    var comment: String = ""
    var totalAmountInOrder: Double? {
        if category == .RoomService {
            var total = 0.0
            for item in foodItems { total += item.totalPrice }
            return total
        } else {
            return nil
        }
    }
    mutating func setStatus(status: OrderStatus) {
        statusHistory.append(status)
    }
    init(category: OrderCategory) {
        self.category = category
    }
}


extension Order6 {
    mutating func addRoomItem(item: RoomItem) {
        if let index = roomItems.firstIndex(where: { $0.item.name == item.name } ) {
            roomItems[index].quantity += 1
        } else {
            var orderItem = RoomOrderItem(item: item)
            orderItem.quantity = 1
            roomItems.append(orderItem)
        }
    }

    mutating func removeRoomItem(item: RoomItem) -> Bool {
        if let index = roomItems.firstIndex(where: { $0.item == item } ) {
            roomItems[index].quantity -= 1
            if roomItems[index].quantity <= 0 { roomItems.remove(at: index) }
            return true
        }
        return false
    }

    var totalNrOfRoomItems: Int {
        return roomItems.reduce(0, { $0 + $1.quantity })
    }
}

extension Order6 {
    mutating func addFoodItem(item: FoodOrderItem) {
        foodItems.append(item)
    }
    
    mutating func removeFoodItem(item: FoodOrderItem) -> Bool {
        if let index = foodItems.firstIndex(where: { $0 == item } ) {
            foodItems[index].quantity -= 1
            if foodItems[index].quantity <= 0 { foodItems.remove(at: index) }
            return true
        }
        return false
    }

    func getFoodItem(byItem item: MenuItem) -> FoodOrderItem? {
        return foodItems.first(where: { $0.item == item } )
    }

    var totalNrOfFoodItems: Int {
        return foodItems.reduce(0, { $0 + $1.quantity })
    }
}


struct Order6InDB: Codable {
    private (set) var id: String?
    private (set) var number: Int
    private (set) var roomNumber: Int
    private (set) var statusHistory: [OrderStatus]?
    private (set) var comment: String?
    private (set) var category: OrderCategory
    private (set) var roomItems: [RoomOrderItemInDB]? = nil
    private (set) var buggyItem: BuggyOrderItemInDB? = nil
    private (set) var foodItems: [FoodOrderItemInDB]? = nil
    init(order: Order6) {
        number = order.number
        roomNumber = order.roomNumber
        statusHistory = order.statusHistory
        comment = order.comment
        category = order.category
        roomItems = order.roomItems
        buggyItem = order.buggyItem
        foodItems = order.foodItems.map { FoodOrderItemInDB(f: $0) }
    }
}

extension Order6 {
    init(id: String, orderInDb: Order6InDB) {
        self.id = id
        number = orderInDb.number
        roomNumber = orderInDb.roomNumber
        statusHistory = orderInDb.statusHistory ?? []
        comment = orderInDb.comment ?? ""
        category = orderInDb.category
        roomItems = orderInDb.roomItems ?? []
        buggyItem = orderInDb.buggyItem
        foodItems = orderInDb.foodItems?.compactMap { FoodOrderItem(f: $0) } ?? []
    }
}

