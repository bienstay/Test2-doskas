//
//  ReviewTableViewCell.swift
//  Test2
//
//  Created by maciulek on 11/06/2022.
//

import UIKit

class ReviewTableViewCell: UITableViewCell {
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var reviewTextLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet var roomNumberLabel: UILabel!

    var emptyStar = UIImage(named: "star")
    var fullStar = UIImage(named: "star.fill")

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        if #available(iOS 13.0, *) {
            emptyStar = UIImage(systemName: "star")
            fullStar = UIImage(systemName: "star.fill")
        }
    }

    func draw(timestamp: Date, rating: Int, review: String, roomNumber: Int?, translation: String?) {
        timestampLabel.text = timestamp.formatForDisplay()
        let s = NSMutableAttributedString(string: review)
        if let translation = translation {
            let t = NSMutableAttributedString(string: translation, attributes: [.foregroundColor: UIColor.red])
            s.append(NSAttributedString(string: "\n"))
            s.append(t)
        }
        reviewTextLabel.attributedText = s
        for i in 0 ... stars.count - 1 {
            if i <= rating { stars[i].image = fullStar }
            else { stars[i].image = emptyStar }
        }
        if let roomNumber = roomNumber {
            roomNumberLabel.isHidden = false
            roomNumberLabel.text = String(roomNumber)
        } else {
            roomNumberLabel.isHidden = true
        }
    }
}
