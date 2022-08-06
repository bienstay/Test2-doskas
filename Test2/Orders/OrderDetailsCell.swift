//
//  OrderDetailsCell.swift
//  Test2
//
//  Created by maciulek on 05/06/2021.
//

import UIKit

class OrderDetailsCell: UITableViewCell {
    @IBOutlet weak var categoryImage: UIImageView!
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

    var order: Order6?
    var orgFrame: CGRect? = nil


    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .none
        backgroundColor = .clear
    }

    func draw(order: Order6) {
        glossyView.setNeedsDisplay()
        self.order = order
        statusChangeButton.isHidden = true
//        if phoneUser.isAllowed(to: .manageOrders) {
//            statusChangeButton.isHidden = false
//            if case .CREATED = order.status {
//                statusChangeButton.setTitle("Confirm", for: .normal)
//            }
//            else if case .CONFIRMED = order.status {
//                statusChangeButton.setTitle("Close", for: .normal)
//            } else {
//                statusChangeButton.isHidden = true
//            }
//        }
//        else {
//            statusChangeButton.isHidden = true
//        }

        categoryImage.image = UIImage(named: order.category.rawValue)
        idLabel.text = String(order.number)
        roomLabel.text = .room
        roomNumberLabel.text = String(order.roomNumber)
        //descriptionLabel.text = order.category.toString()
        statusLabel.text = order.status.toString()
        timeLabel.text = order.status.done.at.formatShort()

        switch order.status {
            case .CREATED: statusLabel.textColor = .red
            case .CONFIRMED: statusLabel.textColor = .darkYellow
            case .DELIVERED: statusLabel.textColor = .darkGreen
            case .CANCELED: statusLabel.textColor = .black
            default: statusLabel.textColor = .black
        }
/*
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
 */
    }

    @IBAction func statusChangePressed(_ sender: Any) {
        if case .CREATED = order?.status {
//            dbProxy.updateOrderStatus(orderId: order!.id, newStatus: .CONFIRMED(at: Date(), by: phoneUser.displayName))
        } else
        if case .CONFIRMED = order?.status {
  //          dbProxy.updateOrderStatus(orderId: order!.id, newStatus: .DELIVERED(at :Date()), by: phoneUser.displayName))
        }
    }
    /*
    override func layoutSubviews() {
        super.layoutSubviews()
        if orgFrame == nil {
            orgFrame = layer.frame.inset(by: UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16));
        }
        layer.frame = orgFrame ?? .zero

        super.layoutSubviews()
    }
*/
}

