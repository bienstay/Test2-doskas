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

    @IBOutlet private weak var quantityStackView: UIStackView!
    @IBOutlet private weak var largeIcon: UIImageView!
    @IBOutlet private weak var countLabel: UILabel!
    @IBOutlet private weak var minusButton: UIButton!
    @IBOutlet private weak var plusButton: UIButton!
    @IBOutlet weak var smallIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var largeIconConstraint: NSLayoutConstraint!

    var buttonTappedClosure : ((Bool) -> Void)?
    @IBAction func minusPressed(_ sender: UIButton) {
        buttonTappedClosure?(false)
    }
    @IBAction func plusPressed(_ sender: UIButton) {
        buttonTappedClosure?(true)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        icon.layer.cornerRadius = icon.bounds.height/2.0
    }

    func display(menuItem: MenuItem2, order: Order, expanded: Bool, orderEnabled: Bool) {
        titleLabel.text = menuItem.title
        priceLabel.text = "$" + String(format: "%g", menuItem.price)
        descriptionLabel.text = menuItem.txt
        cuisineLabel.text = menuItem.attributes?.joined(separator: " ")

        if icon.image == nil || expanded { smallIconWidthConstraint.isActive = true }
        else { smallIconWidthConstraint.isActive = false }

        if largeIcon.image == nil || !expanded { largeIconConstraint.constant = 0 }
        else { largeIconConstraint.constant = UIScreen.main.bounds.height * 0.5 }

        let count = order.getItem(byString: menuItem.title)?.quantity ?? 0
        countLabel.text = String(count)
        let isVisible = orderEnabled && (expanded || count > 0)
        quantityStackView.isHidden = !isVisible
    }
}


class MenuGroupCell: UITableViewCell {
    @IBOutlet private weak var groupHeaderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.backgroundColor = .BBbackgroundColor
        groupHeaderLabel.textColor = .orange
    }

    func display(menuItem: MenuItem2) {
        switch menuItem.type {
            case MenuItem2.SECTION: groupHeaderLabel.font = UIFont.preferredFont(forTextStyle: .title2)
            case MenuItem2.GROUP :  groupHeaderLabel.font = UIFont.preferredFont(forTextStyle: .title3)
            default: break
        }
        groupHeaderLabel.text = menuItem.title
    }
}

