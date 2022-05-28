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

    var restaurant: Restaurant = Restaurant()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupTransparentNavigationBar(tableView: tableView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        endTransparentNavigationBar()
    }

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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailTextCell.self), for: indexPath) as! RestaurantDetailTextCell
            cell.draw(text: restaurant._description)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailMapCell.self), for: indexPath) as! RestaurantDetailMapCell
            cell.draw(restaurant.geoLongitude, restaurant.geoLatitude)
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = pushOrPresent(storyBoard: "Menu", id: "MenuMainViewController") as! MenuMainViewController
            vc.restaurant = restaurant
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
    @IBOutlet var ratingImageView: UIImageView!
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
