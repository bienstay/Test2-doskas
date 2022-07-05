//
//  OfferViewController.swift
//  Test2
//
//  Created by maciulek on 23/11/2021.
//

import UIKit

class OfferViewController: UIViewController {
    var offer = Offer()
    var reviewsManager = ReviewsManager()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: OfferHeaderView!
    @IBOutlet weak var reviewButton: UIButton!

    enum Sections: Int, CaseIterable {
        case Details
        case Reviews
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.contentInsetAdjustmentBehavior = .never
        
        // Configure header view
        headerView.titleLabel.text = offer._title
        headerView.subTitleLabel.text = offer._subtitle
        
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

        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        reviewsManager.delegate = self
        reviewsManager.start(group: "offer", id: offer.id ?? "")
    }

    deinit {
        reviewsManager.stop()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar()
        reviewButton.isHidden = phoneUser.isStaff
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }

    @IBAction func requestBookingButtonPressed(_ sender: UIButton) {
    }

    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if let vc = self.prepareModal(storyBoard: "Reviews", id: "RateReview") as? RateReviewViewController {
            vc.group = "offer"
            vc.id = offer.id ?? ""
            vc.reviewTitle = offer.title
            vc.reviewedImage = UIImage(named: "JaNaPlaya")
            present(vc, animated: true)
        }
    }
}

extension OfferViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        switch Sections(rawValue: section) {
            case .Details : return 1
            case .Reviews: return reviewsManager.reviews.count
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .Details:
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
        case .Reviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
            let r = reviewsManager.reviews[indexPath.row]
            cell.draw(timestamp: r.timestamp, rating: r.rating, review: r.review, roomNumber: r.roomNumber, translation: reviewsManager.translations[r.id ?? ""])
            return cell
        default:
            return UITableViewCell()
        }
    }
}

extension OfferViewController: ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .right)
            self.tableView.endUpdates()
        }
    }
    
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .fade)
            self.tableView.endUpdates()
        }
    }

}

class OfferHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
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
}


class OfferCell: UITableViewCell {

    @IBOutlet var offerTextLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
