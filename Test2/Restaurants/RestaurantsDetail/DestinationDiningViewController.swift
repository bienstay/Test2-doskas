//
//  DestinationDiningViewController.swift
//  Test2
//
//  Created by maciulek on 20/05/2021.
//

import UIKit
/*
class DestinationDiningViewController: UIViewController {
    var ddItem = DestinationDiningItem()

    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: RestaurantDetailHeaderView!
    @IBOutlet var requestBookingButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeLocationLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        tableView.contentInsetAdjustmentBehavior = .never

        // Configure header view
        headerView.nameLabel.text = ddItem.title
        headerView.typeLabel.text = ddItem.description
        headerView.headerImageView.image = UIImage(named: ddItem.image)

        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none

        requestBookingButton.superview?.backgroundColor = .BBbackgroundColor

        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.hidesBarsOnSwipe = true
        
        titleLabel.text = ddItem.title
        timeLocationLabel.text = ddItem.timeLocation
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.hidesBarsOnSwipe = false
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func requestBookingButtonPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuMainViewController") as! MenuMainViewController
        //vc.restaurant = restaurant!
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension DestinationDiningViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: String("DetailsCell"), for: indexPath) as! DestinationDiningCell
            cell.descriptionLabel.text = ddItem.description
            cell.priceLabel.text = ddItem.price
            return cell
        default:
            //fatalError("Failed to instantiate the table view cell for detail view controller")
            return UITableViewCell()
        }
    }
}

class DestinationDiningCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
*/
