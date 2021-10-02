//
//  RestaurantDetailViewController.swift
//  FoodPin
//
//  Created by maciulek on 31/03/2021.
//

import UIKit
import Kingfisher

class RestaurantDetailViewController: UIViewController {

    var restaurant: Restaurant?

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInsetAdjustmentBehavior = .never   // hides the navigationbar

        // Configure header view
        headerView.nameLabel.text = restaurant?.name
        headerView.typeLabel.text = restaurant?.cuisines[0]
        //headerView.headerImageView.image = UIImage(data: restaurant!.image)
        headerView.headerImageView.kf.setImage(with: URL(string: restaurant!.image))
        //displayHeart()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //tableView.contentInsetAdjustmentBehavior = .never

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .white
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "expandMap":
            let destinationController = segue.destination as! MapViewController
            destinationController.restaurant = restaurant
        case "showReview":
            let destinationController = segue.destination as! ReviewViewController
            destinationController.restaurant = restaurant
        default: break
        }
    }

    // closing the review scene with X
    @IBAction func close(segue: UIStoryboardSegue) {
        dismiss(animated: true, completion: nil)
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
/*
    func displayHeart() {
        headerView.heartButton.tintColor = restaurant!.isFavorite ? .systemYellow : .white
        if #available(iOS 13.0, *) {
            let imageName = restaurant!.isFavorite ? "heart.fill" : "heart"
            headerView.heartButton.setImage(UIImage(systemName: imageName), for: .normal)
        }
        else {
            let imageName = restaurant!.isFavorite ? "suit_heart_fill" : "suit_heart"
            if let myImage = UIImage(named: imageName) {
                let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
                headerView.heartButton.setImage(tintableImage, for: .normal)
            }
        }
    }

    @IBAction func heartPressed(_ sender: UIButton) {
        restaurant!.isFavorite = !restaurant!.isFavorite
        displayHeart()
    }
*/
/*
    func showPopup () {
        var blockViewController: DemoViewController?
        blockViewController = DemoViewController(nibName: "DemoViewController", bundle: nil)
        //make sure to put this over full screen, to allow the transparency
        blockViewController?.modalPresentationStyle = .overFullScreen
        blockViewController?.modalTransitionStyle = .crossDissolve
        self.present(blockViewController!, animated: true)
    }
 */
}

extension RestaurantDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailTextCell.self), for: indexPath) as! RestaurantDetailTextCell
            cell.descriptionLabel.text = restaurant?.description
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell", for: indexPath)
            cell.selectionStyle = .none
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RestaurantDetailMapCell.self), for: indexPath) as! RestaurantDetailMapCell
            cell.configure(restaurant!.geoLongitude, restaurant!.geoLatitude)
            cell.selectionStyle = .none
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            let vc = pushOrPresent(storyBoard: "Menu", id: "MenuMainViewController") as! MenuMainViewController
            vc.restaurant = restaurant!
        }
    }
/*
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.backgroundColor = .green
      }
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            //cell.backgroundColor = .blue
      }
    }
*/
}
