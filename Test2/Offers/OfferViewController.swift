//
//  OfferViewController.swift
//  Test2
//
//  Created by maciulek on 23/11/2021.
//

import UIKit

class OfferViewController: UIViewController {
    var offer = Offer()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: OfferHeaderView!
    @IBOutlet var requestBookingButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.contentInsetAdjustmentBehavior = .never

        // Configure header view
        headerView.titleLabel.text = offer._title
        headerView.subTitleLabel.text = offer._subtitle
        //headerView.headerImageView.image = UIImage(named: offer.imageURL)
        
        if let url = URL(string: offer.imageURL) {
            headerView.headerImageView.isHidden = false
            headerView.headerImageView.contentMode = .scaleAspectFill
            headerView.headerImageView.kf.setImage(with: url)
        } else {
            headerView.headerImageView.contentMode = .scaleAspectFit
            headerView.headerImageView.image = UIImage(named: "JaNaPlaya")
        }

        

        tableView.delegate = self
        tableView.dataSource = self

        //requestBookingButton.superview?.backgroundColor = .BBbackgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTransparentNavigationBar()
    }

    override func viewWillDisappear(_ animated: Bool) {
        endTransparentNavigationBar()
    }

    @IBAction func requestBookingButtonPressed(_ sender: UIButton) {
    }
}

extension OfferViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String("DetailsCell"), for: indexPath) as! OfferCell
            cell.offerTextLabel.text = offer._text
            cell.priceLabel.text = offer.price
            return cell
        default:
            //fatalError("Failed to instantiate the table view cell for detail view controller")
            return UITableViewCell()
        }
    }
}

class OfferHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var titleLabel: UILabel! {
        didSet {
            titleLabel.numberOfLines = 0
            if let customFont = UIFont(name: "Nunito-Bold", size: 40.0) {
                titleLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet var subTitleLabel: UILabel! {
        didSet {
            if let customFont = UIFont(name: "Nunito-Bold", size: 20.0) {
                subTitleLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet var ratingImageView: UIImageView!
}


class OfferCell: UITableViewCell {

    @IBOutlet var offerTextLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
