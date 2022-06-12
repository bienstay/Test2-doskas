//
//  ReviewButtonTableViewCell.swift
//  Test2
//
//  Created by maciulek on 11/06/2022.
//

import UIKit

class ReviewButtonTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        contentView.backgroundColor = .BBbackgroundColor
    }
}
