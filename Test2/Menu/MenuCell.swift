//
//  MenuCell.swift
//  Test2
//
//  Created by maciulek on 16/05/2021.
//

import UIKit

class MenuFoodCell: UITableViewCell {

    @IBOutlet private weak var icon: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!
    @IBOutlet private weak var cuisineLabel: UILabel!
    @IBOutlet private weak var descriptionLabel: UILabel!

    @IBOutlet private weak var enlargedStackView: UIStackView!
    @IBOutlet private weak var largeIcon: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var countLabel2: UILabel!
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet private weak var quantityStackView: UIStackView!

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
        icon.layer.cornerRadius = icon.bounds.height/2.0
    }

    func display(menuItem: MenuItem, order: Order, expanded: Bool, orderEnabled: Bool) {
        titleLabel.text = menuItem.title
        priceLabel.text = "$" + String(format: "%g", menuItem.price)
        descriptionLabel.text = menuItem.description
        cuisineLabel.text = menuItem.attributes?.joined(separator: " ")
        if icon.image == nil { icon.isHidden = true }
        else { icon.isHidden = false }
        icon.isHidden = expanded
        enlargedStackView.isHidden = !expanded

        countLabel.text = String(order.getItem(byString: menuItem.title)?.quantity ?? 0)
        countLabel2.text = countLabel.text
        countLabel2.isHidden = expanded || countLabel2.text == "0"
        quantityStackView.isHidden = !orderEnabled
    }
}


class MenuGroupCell: UITableViewCell {
    @IBOutlet private weak var groupHeaderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .BBbackgroundColor
        groupHeaderLabel.textColor = .orange
    }

    func display(menuItem: MenuItem) {
        groupHeaderLabel.text = menuItem.title
    }
}

