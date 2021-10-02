//
//  RestaurantDestinationDiningCell.swift
//  Test2
//
//  Created by maciulek on 17/05/2021.
//

import UIKit

class RestaurantDestinationDiningCell: UITableViewCell {

    @IBOutlet weak var groupTitleLabel: UILabel!
    @IBOutlet weak var groupSubLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!

    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.backgroundColor = .BBbackgroundColor
    }

    func setCollectionViewDataSourceDelegate(dataSourceDelegate: UICollectionViewDataSource & UICollectionViewDelegate, forRow: Int) {
        collectionView.delegate = dataSourceDelegate
        collectionView.dataSource = dataSourceDelegate
        collectionView.tag = forRow
        collectionView.reloadData()
    }
}

class RestaurantDestinationDiningCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLocationLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        timeLocationLabel.textColor = .red
        picture.layer.cornerRadius = 10
    }
}
