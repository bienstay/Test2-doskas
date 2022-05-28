//
//  NewInfoImagesTableViewCell.swift
//  Test2
//
//  Created by maciulek on 24/05/2022.
//

import UIKit
import Kingfisher

class NewInfoImagesTableViewCell: UITableViewCell {
    @IBOutlet private var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NewInfoImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var deleteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .BBbackgroundColor
        picture.layer.cornerRadius = 10
    }

    func draw(title: String, image: UIImage?) {
        titleTextField.text = title
        picture.image = image
        deleteButton.isHidden = picture.image == nil

    }
}
