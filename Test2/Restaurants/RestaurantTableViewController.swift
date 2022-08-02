//
//  RestaurantTableViewController.swift
//  FoodPin
//
//  Created by maciulek on 28/03/2021.
//

import UIKit
import Kingfisher


class RestaurantTableViewController: UITableViewController {

    @IBOutlet var emptyRestaurantView: UIView!
    @IBOutlet weak var newRestaurantBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        //tableView.cellLayoutMarginsFollowReadableWidth = true

        tableView.backgroundView = emptyRestaurantView
        tableView.backgroundView?.isHidden = hotel.restaurants.count == 0 ? false : true

        NotificationCenter.default.addObserver(self, selector: #selector(onRestaurantsUpdated(_:)), name: .restaurantsUpdated, object: nil)

        let nib = UINib(nibName: "RestaurantSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "HeaderTableView")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(title: .food)
        newRestaurantBarButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        newRestaurantBarButton.title = phoneUser.isAllowed(to: .editContent) ? "New" : ""
    }

    @objc func onRestaurantsUpdated(_ notification: Notification) {
        DispatchQueue.main.async { self.tableView.reloadData() }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Restaurants", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "RestaurantDetail") as! RestaurantDetailViewController
        vc.restaurant = hotel.restaurants[indexPath.row]
        self.pushOrPresent(viewController: vc)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return hotel.restaurants.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let restaurant = hotel.restaurants[indexPath.row]
        let cellName = "bigcell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellName, for: indexPath) as! RestaurantTableViewCell
        cell.nameLabel?.text = restaurant.name
        cell.thumbnailImageView?.kf.setImage(with: URL(string: restaurant.image))
        cell.locationLabel.text = restaurant._location
        cell.typeLabel.text = restaurant._cuisines
        return cell
    }

    @IBAction func newRestaurantPressed(_ sender: Any) {
        let vc = self.createViewController(storyBoard: "Restaurants", id: "NewRestaurant") as! NewRestaurantController
        self.navigationController?.pushViewController(vc, animated: true)
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .normal, title: "Edit") { action, view, completionHandler in
            let vc = self.createViewController(storyBoard: "Restaurants", id: "NewRestaurant") as! NewRestaurantController
            vc.restaurantToEdit = hotel.restaurants[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            self.deleteRestaurant(restaurant: hotel.restaurants[indexPath.row])
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func deleteRestaurant(restaurant: Restaurant) {
        let errStr = dbProxy.removeRecord(key: restaurant.id, record: restaurant) { [weak self] record in
            if record == nil {
                self?.showInfoDialogBox(title: "Error", message: "Restaurant delete failed")
            } else {
                self?.showInfoDialogBox(title: "Info", message: "Restaurant deleted")
            }
        }
        if errStr != nil { Log.log(errStr!) }
    }

}

class RestaurantTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        thumbnailImageView.layer.cornerRadius = 12
    }
}
