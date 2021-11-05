//
//  Order.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation

class RoomItem: Hashable, Codable {
    enum ItemType: String, Codable, Hashable, CaseIterable {
        //case Services = "Services"
        case Toiletries = "Toiletries"
        case BathAmenities = "Bath Amenities"
        case RoomAmenities = "Room Amenities"
        case RoomConsumables = "Room Consumables"
        case None = ""
    }
    static func == (lhs: RoomItem, rhs: RoomItem) -> Bool {
        return lhs.name == rhs.name && lhs.type == rhs.type
    }
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self))
    }
    
    var name: String = ""
    var type: ItemType = .Toiletries
    var picture: String = ""
    var color: String = "000000"
    var maxQuantity: Int = 5
}

class Order: Codable {
    enum Category: String, Codable, Hashable, CaseIterable {
        case RoomService = "In-room dining"
        case Maintenance = "Maintenance"
        case Cleaning = "Cleaning"
        case LuggageService = "Luggage"
        case Buggy = "Buggy"
        case RoomItems = "Room Items"
        case None = ""
    }

    struct OrderItem: Codable {
        var name: String
        var quantity: Int
        var price: Double
    }

    enum Status: String {
        case CREATED  = "Created"
        case CONFIRMED = "Confirmed"
        case DELIVERED = "Delivered"
        case CANCELED = "Canceled"
    }

    var id: String?

    private (set) var number: Int = 0
    private (set) var roomNumber: Int
    private (set) var category: Category = .RoomItems

    private (set) var created: Date?
    private (set) var confirmed: Date?
    private (set) var delivered: Date?
    private (set) var canceled: Date?

    private (set) var createdBy: String?
    private (set) var confirmedBy: String?
    private (set) var deliveredBy: String?
    private (set) var canceledBy: String?

    private (set) var items: [OrderItem] = []
    var guestComment: String?

    init(roomNumber: Int, category: Category) {
        self.roomNumber = roomNumber
        self.category = category
    }

    func setCreated(orderNumber: Int) {
        created = Date()
        number = orderNumber
        roomNumber = guest.roomNumber
        createdBy = guest.isAdmin() ? guest.Name : String(guest.roomNumber)
        //id = created!.formatFull() + "_" + String(roomNumber) + "_" + String(number)
    }

    func addItem(name: String, quantity: Int, price: Double = 0.0) {
        if let index = items.firstIndex(where: { $0.name == name } ) {
            items[index].quantity += quantity
        } else {
            let item = OrderItem(name: name, quantity: quantity, price: price)
            items.append(item)
        }
    }

    func removeItem(name: String, quantity: Int) -> Bool {
        if let index = items.firstIndex(where: { $0.name == name } ) {
            items[index].quantity -= 1
            if items[index].quantity <= 0 { items.remove(at: index) }
            return true
        }
        return false
    }
    
    func getItem(byString name: String) -> OrderItem? {
        if let index = items.firstIndex(where: { $0.name == name } ) {
            return items[index]
        } else {
            return nil
        }
    }

    var totalNrOfItemsInOrder: Int {
        return items.reduce(0, { $0 + $1.quantity })
    }

    var totalAmountInOrder: Double {
        var total = 0.0
        items.forEach( { total += $0.price } )
        return total
    }

    func setStatus(status: Status) {
        switch status {
        case .CREATED: created = Date()
        case .CONFIRMED: confirmed = Date()
        case .DELIVERED: delivered = Date()
        case .CANCELED: canceled = Date()
        }
    }

    var status: Status {
        if canceled != nil { return .CANCELED }
        if delivered != nil { return .DELIVERED }
        if confirmed != nil { return .CONFIRMED }
        return .CREATED
    }
    
    var updateTime: Date? {
        if delivered != nil { return delivered }
        if confirmed != nil { return confirmed }
        return created
    }
}


struct OrderInDB: Codable {
    private (set) var description: String   // TODO - change in DB and here to category
    private (set) var number: Int
    private (set) var roomNumber: Int

    private (set) var created: Date?
    private (set) var confirmed: Date?
    private (set) var delivered: Date?
    private (set) var canceled: Date?

    private (set) var createdBy: String?
    private (set) var confirmedBy: String?
    private (set) var deliveredBy: String?
    private (set) var canceledBy: String?

    private (set) var items: [Order.OrderItem]?
    var guestComment: String?
    
    init(order: Order, roomNumber: Int? = nil) {
        self.description = order.category.rawValue
        self.number = order.number
        self.roomNumber = roomNumber != nil ? roomNumber! : order.roomNumber
        self.created = order.created
        self.confirmed = order.confirmed
        self.delivered = order.delivered
        self.canceled = order.canceled
        self.createdBy = order.createdBy
        self.confirmedBy = order.confirmedBy
        self.deliveredBy = order.deliveredBy
        self.items = order.items.isEmpty ? nil : order.items
        self.guestComment = order.guestComment
    }
}

extension Order {
    convenience init(id: String, orderInDb: OrderInDB) {
        self.init(roomNumber: orderInDb.roomNumber, category: Order.Category(rawValue: orderInDb.description) ?? .None)
        self.id = id
        self.category = Order.Category(rawValue: orderInDb.description) ?? .None
        self.number = orderInDb.number
        self.roomNumber = orderInDb.roomNumber
        self.created = orderInDb.created
        self.confirmed = orderInDb.confirmed
        self.delivered = orderInDb.delivered
        self.canceled = orderInDb.canceled
        self.createdBy = orderInDb.createdBy
        self.confirmedBy = orderInDb.confirmedBy
        self.deliveredBy = orderInDb.deliveredBy
        self.canceledBy = orderInDb.canceledBy
        self.items = orderInDb.items ?? []
        self.guestComment = orderInDb.guestComment
    }
}
