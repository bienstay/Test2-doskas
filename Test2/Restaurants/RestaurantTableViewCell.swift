//
//  RestaurantTableViewCell.swift
//  FoodPin
//
//  Created by maciulek on 29/03/2021.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        thumbnailImageView.layer.cornerRadius = 15
    }
}
