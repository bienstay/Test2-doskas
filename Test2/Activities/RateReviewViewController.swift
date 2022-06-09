//
//  RateReviewViewController.swift
//  Test2
//
//  Created by maciulek on 04/06/2022.
//

import UIKit

class RateReviewViewController: UIViewController {
    @IBOutlet weak var rateLabel: UILabel!
    @IBOutlet var rateButtons: [UIButton]!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var reviewTextView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var image: UIImageView!

    var group: String?
    var id: String?
    var reviewTitle: String?
    var reviewedImage: UIImage?

    var rating = -1
    var emptyStar = UIImage(named: "star")
    var fullStar = UIImage(named: "star.fill")

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            emptyStar = UIImage(systemName: "star")
            fullStar = UIImage(systemName: "star.fill")
        }
        for i in 0...rateButtons.count - 1 {
            rateButtons[i].tag = i
            rateButtons[i].setImage(emptyStar, for: .normal)
        }
        sendButton.isEnabled = false
        image.image = reviewedImage
        if let reviewTitle = reviewTitle {
            rateLabel.text = reviewTitle
        }
    }

    @IBAction func rateButtonPressed(_ sender: UIButton) {
        rating = sender.tag
        for b in rateButtons { b.setImage(emptyStar, for: .normal) }
        for i in 0...sender.tag { rateButtons[i].setImage(fullStar, for: .normal) }
        sendButton.isEnabled = true
    }

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let group = group, let id = id else { return }
        let review = Review(id: nil, timestamp: Date(), rating: rating, review: reviewTextView.text, roomNumber: phoneUser.roomNumber, userId: phoneUser.id)
        _ = dbProxy.addRecord(key: nil, subNode: "\(group)/\(id)", record: review) { [weak self] _,_ in
               self?.dismiss(animated: true)
        }
//        dbProxy.writeReview(group: "news", id: Date().formatForDB(), rating: rating, review: reviewTextView.text) { [weak self] in
//            self?.dismiss(animated: true)
//        }
    }
}
