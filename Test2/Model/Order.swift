//
//  Order.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import Foundation

enum RoomItemType: String, Codable, Hashable {
    case Service
    case Toiletries
    case BathAmenities
    case RoomAmenities
    case RoomConsumables
    case Maintenance
    func toInt() -> Int {
        switch self {
        case .Service: return 0
        case .Toiletries: return 1
        case .BathAmenities: return 2
        case .RoomAmenities: return 3
        case .RoomConsumables: return 4
        case .Maintenance: return 99
        }
    }
    static func fromInt(_ i: Int) -> RoomItemType {
        switch i {
            case 0: return .Service
            case 1: return .Toiletries
            case 2: return .BathAmenities
            case 3: return .RoomAmenities
            case 4: return .RoomConsumables
            default: return .Maintenance
        }
    }
}

class RoomItem: Hashable, Codable {
    static func == (lhs: RoomItem, rhs: RoomItem) -> Bool {
        return lhs.name == rhs.name && lhs.category == rhs.category
    }
    public func hash(into hasher: inout Hasher) {
         hasher.combine(ObjectIdentifier(self))
    }
    
    var name: String = ""
    var category: RoomItemType = .Toiletries
    var picture: String = "watchBell"
    var color: String = "000000"
    var maxQuantity: Int = 5
}

class Order: Codable {

    struct OrderItem: Codable {
        var name: String
        var quantity: Int
        var price: Double
    }

    enum Status: String {
        case CREATED  = "created"
        case CONFIRMED = "confirmed"
        case DELIVERED = "delivered"
        case CANCELED = "canceled"
    }

    var id: String?

    private (set) var description: String = ""
    private (set) var number: Int = 0
    private (set) var roomNumber: Int

    private (set) var created: Date?
    private (set) var confirmed: Date?
    private (set) var delivered: Date?
    private (set) var canceled: Date?

    private (set) var createdBy: String?
    private (set) var confirmedBy: String?
    private (set) var deliveredBy: String?

    private (set) var items: [OrderItem] = []
    var guestComment: String?

    init(roomNumber: Int, description: String) {
        self.roomNumber = roomNumber
        self.description = description
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
    private (set) var description: String
    private (set) var number: Int
    private (set) var roomNumber: Int

    private (set) var created: Date?
    private (set) var confirmed: Date?
    private (set) var delivered: Date?
    private (set) var canceled: Date?

    private (set) var createdBy: String?
    private (set) var confirmedBy: String?
    private (set) var deliveredBy: String?

    private (set) var items: [Order.OrderItem]
    var guestComment: String?
    
    init(order: Order, roomNumber: Int? = nil) {
        self.description = order.description
        self.number = order.number
        self.roomNumber = roomNumber != nil ? roomNumber! : order.roomNumber
        self.created = order.created
        self.confirmed = order.confirmed
        self.delivered = order.delivered
        self.canceled = order.canceled
        self.createdBy = order.createdBy
        self.confirmedBy = order.confirmedBy
        self.deliveredBy = order.deliveredBy
        self.items = order.items
        self.guestComment = order.guestComment
    }
}

extension Order {
    convenience init(id: String, orderInDb: OrderInDB) {
        self.init(roomNumber: orderInDb.roomNumber, description: orderInDb.description)
        self.id = id
        self.description = orderInDb.description
        self.number = orderInDb.number
        self.roomNumber = orderInDb.roomNumber
        self.created = orderInDb.created
        self.confirmed = orderInDb.confirmed
        self.delivered = orderInDb.delivered
        self.canceled = orderInDb.canceled
        self.createdBy = orderInDb.createdBy
        self.confirmedBy = orderInDb.confirmedBy
        self.deliveredBy = orderInDb.deliveredBy
        self.items = orderInDb.items
        self.guestComment = orderInDb.guestComment
    }
}
