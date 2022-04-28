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
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!

    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var glossyView: UIView!

    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var itemPriceLabel: UILabel!

    var order: Order?

    override func awakeFromNib() {
        super.awakeFromNib()
        //contentView.backgroundColor = .BBbackgroundColor
        backgroundColor = .clear
        selectionStyle = .none
    }

    func draw(order: Order) {
        glossyView.setNeedsDisplay()
        self.order = order
        if phoneUser.isStaff {
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
        roomLabel.text = .room
        roomNumberLabel.text = String(order.roomNumber)
        descriptionLabel.text = order.category.toString()
        statusLabel.text = order.status.toString()

        switch order.status {
            case .CREATED: statusLabel.textColor = .red
            case .CONFIRMED: statusLabel.textColor = .darkYellow
            case .DELIVERED: statusLabel.textColor = .darkGreen
            case .CANCELED: statusLabel.textColor = .black
        }
        if let date = order.created {
            timeLabel.text = date.formatForDisplay()
        }

        itemNameLabel.text = ""
        itemCountLabel.text = ""
        itemPriceLabel.text = ""
        for item in order.items {
            var s = ""
            //if let lang = Locale.current.languageCode, let itemList = String.roomItemsList[lang], order.category == .RoomItems {
            if let itemList = String.roomItemsList[phoneUser.lang], order.category == .RoomItems {
                s = itemList[item.name] ?? ""
            } else {
                s = item.name
            }
            itemNameLabel.text?.append(s)
            itemNameLabel.text?.append("\n")
            itemCountLabel.text?.append(String(item.quantity))
            itemCountLabel.text?.append("\n")
            itemPriceLabel.text?.append(String(item.price))
            itemPriceLabel.text?.append("\n")
        }
        separatorView.isHidden = order.items.isEmpty
    }

    @IBAction func statusChangePressed(_ sender: Any) {
        if order?.status == Order.Status.CREATED {
            dbProxy.updateOrderStatus(orderId: order!.id!, newStatus: .CONFIRMED, confirmedBy: phoneUser.toString())
        } else
        if order?.status == Order.Status.CONFIRMED {
            dbProxy.updateOrderStatus(orderId: order!.id!, newStatus: .DELIVERED, deliveredBy: phoneUser.toString())
        }
    }
}

