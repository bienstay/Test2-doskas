//
//  NewsCell.swift
//  Test2
//
//  Created by maciulek on 09/06/2021.
//

import UIKit
import Kingfisher

class NewsCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
/*
        let bgColor: UIColor = .BBbackgroundColor
        let contentColor: UIColor = .BBbackgroundColor
        // cell backgroundcolor
        backgroundColor = bgColor
        // content view background
        contentView.backgroundColor = contentColor
*/
        selectionStyle = UITableViewCell.SelectionStyle.none
        backgroundColor = .clear
        newsImageView.layer.cornerRadius = 15
        newsImageView.layer.masksToBounds = true
    }

    func draw(post: NewsPost) {
        titleLabel.text = post.title
        subtitleLabel.text = post.subtitle
        timestampLabel.text = post.timestamp.formatFriendly()
        newsImageView.image = nil
        if let url = URL(string: post.imageFileURL) {
            newsImageView.isHidden = false
            newsImageView.kf.setImage(with: url, placeholder: UIImage(named: "Lukasz"), options: [.transition(.fade(1))]) {
                result in
                switch result {
                case .success(_):
                //case .success(let value):
                //    print("KF Task done for: \(value.source.url?.absoluteString ?? "")")
                    break;
                case .failure(let error):
                    print("KF setImage Job failed: \(error.localizedDescription)")
                }
            }
        }
        else { newsImageView.isHidden = true }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
