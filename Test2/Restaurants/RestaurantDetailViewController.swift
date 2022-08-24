//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by maciulek on 31/03/2021.
//

import UIKit
import Kingfisher
import MapKit

class RestaurantDetailViewController: UIViewController {

    enum Sections: Int, CaseIterable {
        case details
        case reviews
    }
    enum Rows: Int, CaseIterable {
        case text
        case map
    }
    var restaurant: Restaurant = Restaurant()
    var reviewsManager = ReviewsManager()


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: RestaurantDetailHeaderView!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBAction func rateItPressed(_ sender: UIButton) {
        let vc = pushOrPresent(storyBoard: "Restaurants", id: "Review") as! ReviewViewController
        vc.restaurant = restaurant
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self

        // Configure header view
        headerView.nameLabel.text = restaurant.name
        headerView.typeLabel.text = restaurant._cuisines
        headerView.headerImageView.kf.setImage(with: URL(string: restaurant.image))
        
        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")
        reviewsManager.start(group: "restaurants", id: restaurant.id)
        reviewsManager.delegate = self
    }

    deinit {
        reviewsManager.stop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar(tableView: tableView)
        menuButton.setTitle("Menu", for: .normal)
        reviewButton.isHidden = phoneUser.isStaff
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }
/*
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let headerView = tableView.tableHeaderView else { return }
        //let size = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let size = headerView.systemLayoutSizeFitting(CGSize(width: tableView.bounds.width, height: 0))
        if headerView.frame.size.height != size.height {
            headerView.frame.size.height = size.height
            tableView.tableHeaderView = headerView
            tableView.layoutIfNeeded()
        }
    }
*/
    // closing the review scene with smileys
    @IBAction func rateRestaurant(segue: UIStoryboardSegue) {
        //guard let identifier = segue.identifier else { return }
/*
        dismiss(animated: true, completion: {
//            if let rating = Restaurant.Rating(rawValue: identifier) {
//                self.restaurant?.rating = rating
//                self.headerView.ratingImageView.image = UIImage(named: rating.imageLabel)
//            }

//            let scaleTransform = CGAffineTransform.init(scaleX: 0.1, y: 0.1)
//            self.headerView.ratingImageView.transform = scaleTransform
//            self.headerView.ratingImageView.alpha = 0
//            UIView.animate(withDuration: 4.4, delay: 0, usingSpringWithDamping : 0.3, initialSpringVelocity: 0.7, options: [], animations: {
//                    self.headerView.ratingImageView.transform = .identity
//                    self.headerView.ratingImageView.alpha = 1
//            }, completion: nil)
        })
 */
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        switch Sections(rawValue: section) {
            case .details : return Rows.allCases.count
            case .reviews: return reviewsManager.reviews.count
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .details:
            switch Rows(rawValue: indexPath.row) {
            case .text:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailTextCell.self), for: indexPath) as! RestaurantDetailTextCell
                cell.draw(text: restaurant._description)
                return cell
            case .map:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailMapCell.self), for: indexPath) as! RestaurantDetailMapCell
                cell.draw(restaurant.geoLongitude, restaurant.geoLatitude)
                return cell
            default:
                return UITableViewCell()
            }
        case .reviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
            let r = reviewsManager.reviews[indexPath.row]
            cell.draw(timestamp: r.timestamp, rating: r.rating, review: r.review, roomNumber: r.roomNumber, translation: reviewsManager.translations[r.id ?? ""])
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != Sections.reviews.rawValue || reviewsManager.reviews.isEmpty { return nil }
        return "Reviews"
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch Sections(rawValue: section) {
            case .details: return 40
            case .reviews: return 0
            default: return 0
        }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView, !reviewsManager.reviews.isEmpty else { return }
        headerView.tintColor = .orange
        headerView.textLabel?.textColor = .black
    }

    @IBAction func menuPressed(_ sender: UIButton) {
        let vc = pushOrPresent(storyBoard: "Menu", id: "MenuMainViewController") as! MenuMainViewController
        vc.restaurant = restaurant
    }
    
    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if let vc = self.prepareModal(storyBoard: "Activities", id: "RateReview") as? RateReviewViewController {
            vc.group = "restaurants"
            vc.id = restaurant.id
            vc.reviewTitle = restaurant.name
            vc.reviewedImage = UIImage(named: "JaNaPlaya")
            present(vc, animated: true)
        }
    }

}

extension RestaurantDetailViewController: ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections([Sections.reviews.rawValue], with: .fade)
            self?.tableView.endUpdates()
            self?.headerView.updateReviewTotals(reviewScore: reviewManager.scoring, reviewCount: reviewManager.count)
        }
    }
    
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections([Sections.reviews.rawValue], with: .fade)
            self?.tableView.endUpdates()
        }
    }
}


class RestaurantDetailHeaderView: UIView {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var nameLabel: UILabel! {
        didSet {
            nameLabel.numberOfLines = 0
            if let customFont = UIFont(name: "Nunito-Bold", size: 40.0) {
                nameLabel.font = UIFontMetrics(forTextStyle: .title1).scaledFont(for: customFont)
            }
        }
    }
    @IBOutlet var typeLabel: UILabel! {
        didSet {
            if let customFont = UIFont(name: "Nunito-Bold", size: 20.0) {
                typeLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: customFont)
            }
        }
    }
    //@IBOutlet var ratingImageView: UIImageView!
    @IBOutlet weak var reviewScoreLabel: UILabel!
    @IBOutlet weak var reviewCountLabel: UILabel!

    func updateReviewTotals(reviewScore: Double, reviewCount: Int) {
        reviewScoreLabel.text = String(format: "%.1f", reviewScore)
        reviewCountLabel.text = String("(\(reviewCount))")
    }
}


class RestaurantDetailTextCell: UITableViewCell {
    @IBOutlet private var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func draw(text: String) {
        descriptionLabel.text = text
    }
}

class RestaurantDetailMenuCell: UITableViewCell {
    @IBOutlet weak var actionButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(buttonTitle: String, tag: Int, target: Any?, action: Selector) {
        actionButton.setTitle(buttonTitle, for: .normal)
        actionButton.tag = tag
        actionButton.addTarget(target, action: action, for: .touchUpInside)
    }
}

class RestaurantDetailMapCell: UITableViewCell {

    @IBOutlet var mapView: MKMapView!

    override func awakeFromNib() { super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        mapView.layer.cornerRadius = 20.0
        mapView.clipsToBounds = true
    }

    func draw(_ longitude: Double, _ latitude: Double) {
        let coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 250, longitudinalMeters: 250)
        self.mapView.setRegion(region, animated: false)
        self.mapView.addAnnotation(annotation)

        mapView.showsCompass = false
        mapView.showsScale = false
        mapView.showsTraffic = false
        mapView.showsPointsOfInterest = false
        if #available(iOS 13, *) {
            //mapView.pointOfInterestFilter?.excludes(MKPointOfInterestCategory.atm)
            //mapView.pointOfInterestFilter = MKPointOfInterestFilter(
        }
    }

}
