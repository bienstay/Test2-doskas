//
//  OrderDetailsCell.swift
//  Test2
//
//  Created by maciulek on 05/06/2021.
//

import UIKit

class OrderDetailsCell: UITableViewCell {
    @IBOutlet weak var statusChangeButton: UIButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var roomLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!

    var order: Order?

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .BBbackgroundColor
    }
    
    func draw(order: Order) {
        self.order = order
        if guest.isAdmin() {
            statusChangeButton.isHidden = false
            if order.status == Order.Status.CREATED {
                statusChangeButton.setTitle("Confirm", for: .normal)
            } else
            if order.status == Order.Status.CONFIRMED {
                statusChangeButton.setTitle("Close", for: .normal)
            } else {
                statusChangeButton.isHidden = true
            }
        }
        else {
            statusChangeButton.isHidden = true
        }
        
        idLabel.text = String(order.number)
        roomLabel.text = String(order.roomNumber)
        descriptionLabel.text = order.description
        statusLabel.text = order.status.rawValue

        switch order.status {
            case .CREATED: statusLabel.textColor = .red
            case .CONFIRMED: statusLabel.textColor = .darkYellow
            case .DELIVERED: statusLabel.textColor = .darkGreen
            case .CANCELED: statusLabel.textColor = .black
        }
        if let date = order.created {
            timeLabel.text = date.formatFriendly()
        }

        itemNameLabel.text = ""
        itemCountLabel.text = ""
        itemPriceLabel.text = ""
        for item in order.items {
            itemNameLabel.text?.append(item.name)
            itemNameLabel.text?.append("\n")
            itemCountLabel.text?.append(String(item.quantity))
            itemCountLabel.text?.append("\n")
            itemPriceLabel.text?.append(String(item.price))
            itemPriceLabel.text?.append("\n")
        }
    }

    @IBAction func statusChangePressed(_ sender: Any) {
        if order?.status == Order.Status.CREATED {
            FireB.shared.updateOrderStatus(orderId: order!.id!, newStatus: .CONFIRMED, confirmedBy: guest.Name)
        } else
        if order?.status == Order.Status.CONFIRMED {
            FireB.shared.updateOrderStatus(orderId: order!.id!, newStatus: .DELIVERED, deliveredBy: guest.Name)
        }
    }
}

