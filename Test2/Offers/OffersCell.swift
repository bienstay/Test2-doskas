//
//  OffersCell.swift

//
//  Created by maciulek on 20/11/2021.
//

import UIKit
import Kingfisher

class OffersCell: UITableViewCell, UICollectionViewDelegate {

    @IBOutlet weak var newOfferButton: UIButton!
    @IBOutlet private weak var groupTitleLabel: UILabel!
    @IBOutlet private weak var groupSubLabel: UILabel!
    @IBOutlet private var collectionView: UICollectionView!
    private var cellSelectedClosure: ((Int) -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .BBbackgroundColor
        collectionView.backgroundColor = .BBbackgroundColor
        newOfferButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        newOfferButton.isHidden = !phoneUser.isAllowed(to: .editContent)
    }

    func configure(group: Int, title: String, subTitle: String, dataSource: UICollectionViewDataSource, selectionClosure: @escaping (Int) -> ()) {
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
    @IBOutlet weak var deleteButton: UIButton!
    var cellSelectedForEditClosure: ((Offer) -> ())? = nil
    var cellSelectedForDeleteClosure: ((Offer) -> ())? = nil
    var offer: Offer = Offer()

    override func awakeFromNib() {
        super.awakeFromNib()
        picture.layer.cornerRadius = 10
        deleteButton.layer.cornerRadius = 5
        deleteButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        deleteButton.isHidden = !phoneUser.isAllowed(to: .editContent)

        if phoneUser.isAllowed(to: .editContent) {
            contentView.isUserInteractionEnabled = true
            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(didPressLong))
            longPress.minimumPressDuration = 1
            contentView.addGestureRecognizer(longPress)
        }
    }

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        cellSelectedForDeleteClosure?(offer)
    }

    @objc func didPressLong(sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            cellSelectedForEditClosure?(offer)
        }
    }

    func configure(offer: Offer?) {
        if let offer = offer {
            self.offer = offer
            titleLabel.text = offer._title
            if let url = URL(string: offer.imageURL) {
                picture.kf.setImage(with: url)
            } else {
                picture.image = nil
            }
        }
    }
}
