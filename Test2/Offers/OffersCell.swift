//
//  OffersCell.swift

//
//  Created by maciulek on 20/11/2021.
//

import UIKit
import Kingfisher

class OffersCell: UITableViewCell, UICollectionViewDelegate {

    @IBOutlet private weak var groupTitleLabel: UILabel!
    @IBOutlet private weak var groupSubLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    private var cellSelectedClosure: ((Int) -> ())? = nil
    var cellSelectedForEditClosure: ((Int) -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .BBbackgroundColor
        collectionView.backgroundColor = .BBbackgroundColor
    }

    func configure(group: Int, title: String, subTitle: String, dataSource: UICollectionViewDataSource, selectionClosure: @escaping (Int) -> () ) {
        groupTitleLabel.text = title
        groupSubLabel.text = subTitle
        collectionView.dataSource = dataSource
        collectionView.delegate = self
        collectionView.tag = group
        collectionView.reloadData()
        cellSelectedClosure = selectionClosure
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cellSelectedClosure?(indexPath.row)
    }
}

extension OffersCell: UICollectionViewDelegateFlowLayout {

    var cellSize: Double {
        var size: Double = 300.0
        if traitCollection.horizontalSizeClass == .compact {
            size = UIScreen.main.bounds.width * 2.0 / 3.0
        }
        return size
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: cellSize, height: cellSize)
    }
}

class OfferCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    var cellSelectedForEditClosure: ((Offer) -> ())? = nil
    var offer: Offer = Offer()

    override func awakeFromNib() {
        super.awakeFromNib()
        subtitleLabel.textColor = .red
        picture.layer.cornerRadius = 10

        contentView.isUserInteractionEnabled = true
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didPressLong))
        longPress.minimumPressDuration = 1
        contentView.addGestureRecognizer(longPress)
    }

    @objc func didPressLong(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cellSelectedForEditClosure?(offer)
        }
    }

    func configure(offer: Offer?) {
        if let offer = offer {
            self.offer = offer
            titleLabel.text = offer.title
            subtitleLabel.text = offer.subTitle
            if let url = URL(string: offer.imageURL) {
                picture.kf.setImage(with: url)
            } else {
                picture.image = nil
            }
        }
    }
}
