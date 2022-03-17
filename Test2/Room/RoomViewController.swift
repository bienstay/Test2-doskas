//
//  RoomViewController.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var order = Order(roomNumber: guest.roomNumber, category: .RoomItems)

    @IBOutlet weak var orderSummaryConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var orderShortSummaryView: OrderShortSummaryView!

    struct DisplayData {
        var expanded: Bool = false
    }
    
    var observer: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.allowsSelection = true

        // observe changes to the navigation bar size and set different title
        self.observer = self.navigationController?.navigationBar.observe(\.bounds, options: [.new], changeHandler: { (navigationBar, changes) in
                let heightForCollapsedNav = UINavigationController().navigationBar.frame.size.height
                if let height = changes.newValue?.height {
                    self.navigationItem.title = height > heightForCollapsedNav ? .room + " \(guest.roomNumber)" : .room + " \(guest.roomNumber) - \(guest.Name)"
                }
            })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupListNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false

        tabBarController?.tabBar.isHidden = false
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomHeaderCell2", for: indexPath) as! RoomHeaderCell2
        cell.tapClosure = { category in self.maintenancePressed(category: category) }
        cell.display(indexPath.row)
        return cell
    }

    func maintenancePressed(category: Order.Category) {
        switch (category) {
        case .Buggy:
            let vc = pushViewController(storyBoard: "OrderSummary", id: "BuggyOrder") as! BuggyOrderViewController
            vc.category = category
        case .Cleaning, .Maintenance, .LuggageService:
            let vc = pushViewController(storyBoard: "OrderSummary", id: "MaintenanceOrder") as! ServiceOrderViewController
            vc.category = category
        case .RoomItems:
            _ = pushViewController(storyBoard: "Room", id: "RoomItemsController")
        case .RoomService:
            let vc = pushViewController(storyBoard: "Menu", id: "MenuViewController") as! MenuViewController
            vc.restaurant = hotel.roomService
            vc.isRoomService = true
        default:
            break;
        }
    }

}


class RoomHeaderCell2: UITableViewCell {
    @IBOutlet private weak var headerTitleLabel1: UILabel!
    @IBOutlet private weak var headerLabel1: UILabel!
    @IBOutlet private weak var headerImage1: UIImageView!
    @IBOutlet private weak var headerTitleLabel2: UILabel!
    @IBOutlet private weak var headerLabel2: UILabel!
    @IBOutlet private weak var headerImage2: UIImageView!
    var tapClosure: ((_ category: Order.Category) -> ())? = nil
    var row: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none

        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTap1))
        headerImage1.addGestureRecognizer(tap1)
        headerImage1.isUserInteractionEnabled = true

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTap2))
        headerImage2.addGestureRecognizer(tap2)
        headerImage2.isUserInteractionEnabled = true
    }

    @objc func didTap1() {
        switch row {
        case 0: tapClosure?(.RoomItems)
        case 1: tapClosure?(.Maintenance)
        case 2: tapClosure?(.LuggageService)
        default: break
        }
    }

    @objc func didTap2() {
        switch row {
        case 0: tapClosure?(.RoomService)
        case 1: tapClosure?(.Cleaning)
        case 2: tapClosure?(.Buggy)
        default: break
        }
    }

    func display(_ row:Int) {
        self.row = row
        headerLabel1.isHidden = true
        headerLabel2.isHidden = true
        headerLabel1.text = ""
        headerLabel2.text = ""
        switch (row) {
        case 0:
            headerTitleLabel1.text = .roomItems
            headerImage1.image = UIImage(named: "Room Items")
            headerTitleLabel2.text = .roomService
            headerImage2.image = UIImage(named: "In-room dining")
        case 1:
            headerTitleLabel1.text = .maintenance
            headerImage1.image = UIImage(named: "Maintenance")
            headerTitleLabel2.text = .cleaning
            headerImage2.image = UIImage(named: "Cleaning")
        case 2:
            headerTitleLabel1.text = .luggageService
            headerImage1.image = UIImage(named: "Luggage")
            headerTitleLabel2.text = .buggy
            headerImage2.image = UIImage(named: "Buggy")
        default: break
        }
    }
}
