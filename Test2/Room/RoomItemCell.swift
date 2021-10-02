//
//  ItemTableViewCell.swift
//  Test1
//
//  Created by maciulek on 27/04/2021.
//

import UIKit

class RoomItemCell: UITableViewCell {

    @IBOutlet private weak var itemLabel: UILabel!
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var itemImage: UIImageView!

    var buttonTappedClosure : ((UITableViewCell, Bool) -> Void)?
    @IBAction func minusPressed(_ sender: UIButton) {
        buttonTappedClosure?(self, false)
    }
    @IBAction func plusPressed(_ sender: UIButton) {
        buttonTappedClosure?(self, true)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        quantityLabel.textColor = .orange
        minusButton.tintColor = .orange
        plusButton.tintColor = .orange
    }

    func display(roomItem: RoomItem, order: Order, expanded: Bool) {
        itemLabel.text = roomItem.name
        quantityLabel.text = String( order.getItem(byString: roomItem.name)?.quantity ?? 0)
        if let hexColor = Int(roomItem.color, radix: 16) {
            itemImage.backgroundColor = UIColor(hexColor)
        } else {
            itemImage.backgroundColor = .gray
        }

        if let image = UIImage(named: roomItem.picture) { itemImage.image = image }
        else { itemImage.image = .none }

        itemImage.image = itemImage.image?.withRenderingMode(.alwaysTemplate)
        itemImage.tintColor = .white
        itemImage.layer.cornerRadius = 10

        minusButton.isHidden = !expanded
        plusButton.isHidden = !expanded
        quantityLabel.isHidden = !expanded
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
