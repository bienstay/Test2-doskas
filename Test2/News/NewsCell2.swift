//
//  NewsCell.swift
//  Test2
//
//  Created by maciulek on 09/06/2021.
//

import UIKit
import Kingfisher
/*
class NewsCell2: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    @IBOutlet weak var heartButton: UIButton!
    @IBOutlet weak var likesLabel: UILabel!

    var post = NewsPost()

    @IBAction func heartPressed(_ sender: UIButton) {
        phoneUser.toggleLike(group: "news", key: post.postId)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .clear
        newsImageView.layer.cornerRadius = 15
        newsImageView.layer.masksToBounds = true
    }

    func draw(post: NewsPost, numLikes: Int) {
        self.post = post

        titleLabel.text = post._title
        subtitleLabel.text = post._subtitle
        timestampLabel.text = post.timestamp.formatForDisplay()
        newsImageView.image = nil
        if let url = URL(string: post.imageFileURL) {
            newsImageView.isHidden = false
            newsImageView.kf.setImage(with: url)
        }
        else { newsImageView.isHidden = true }

        heartButton.setImage(UIImage(named: numLikes > 0 ? "heartFull" : "heartEmpty"), for: .normal)
        likesLabel.text = String(numLikes)
        likesLabel.isHidden = !phoneUser.isStaff
    }
}
*/
