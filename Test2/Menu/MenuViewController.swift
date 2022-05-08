//
//  TestViewController.swift
//  Test2
//
//  Created by maciulek on 04/05/2021.
//

import UIKit

// MARK: - Main class
class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var restaurant: Restaurant = Restaurant()
    var menuIndex = 0
    private var order = Order(category: .RoomService)

    var isRoomService = false

    var expandedCells: Set<Int> = []

    @IBAction func orderSummaryPressed(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "CreateOrder") as! RoomItemsOrderViewController
        vc.order = self.order
        vc.completionHandler = { self.clearOrder() }
        self.pushOrPresent(viewController: vc)
    }
    @IBOutlet weak var orderSummaryButton: UIButton!
    @IBOutlet weak var orderSummaryCount: UILabel!
    @IBOutlet weak var orderSummaryImage: UIImageView!
    @IBOutlet weak var orderSummaryConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var orderShortSummaryView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .offWhiteVeryLight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        orderShortSummaryView.layer.cornerRadius = 20
        orderSummaryConstraint.constant = -80

        orderShortSummaryView.isHidden = !isRoomService
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black

        tabBarController?.tabBar.isHidden = true
        
        title = isRoomService ? .roomService : restaurant.name
        if restaurant.menus.count > 0 { headerLabel.text = restaurant.menus[menuIndex].title }
        resetDisplayData()
        
        tableView.alpha = 0
        // Define the final state (After the animation)
        UIView.animate(withDuration: 0.5, animations: { self.tableView.alpha = 1 })

        orderShortSummaryView.superview?.layoutIfNeeded()
    }

    func resetDisplayData() {
        expandedCells = []
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !restaurant.menus.isEmpty else {return 0}
        return restaurant.menus[menuIndex].items?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let menuItem = restaurant.menus[menuIndex].items?[indexPath.row] else { return UITableViewCell() }
        if menuItem.type == MenuItem2.FOODITEM {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuFoodCell", for: indexPath) as! MenuFoodCell
            cell.display(menuItem: menuItem, order: order, expanded: expandedCells.contains(indexPath.row), orderEnabled: isRoomService)
            cell.buttonTappedClosure = { [weak self] addd in
                guard let self = self else { return }
                if addd { self.addToOrder(indexPath) }
                else { self.removeFromOrder(indexPath)}
//                self.tableView.beginUpdates()
//                self.tableView.reloadRows(at: [indexPath], with: .none)
//                self.tableView.endUpdates()
                self.tableView.reloadData()
            }
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuGroupCell", for: indexPath) as! MenuGroupCell
            cell.display(menuItem: menuItem)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if expandedCells.contains(indexPath.row) { expandedCells.remove(indexPath.row) }
        else { expandedCells.insert(indexPath.row) }

        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

/*
        guard let cell = tableView.cellForRow(at: indexPath) as? MenuFoodCell else { return }
        guard let menuItem = restaurant.menus[menuIndex].items?[indexPath.row] else { return }
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            cell.display(menuItem: menuItem, order: self.order, expanded: self.expandedCells.contains(indexPath.row), orderEnabled: self.isRoomService)
            cell.layoutIfNeeded()
        }, completion: {_ in
//            tableView.layoutIfNeeded()
//                tableView.reloadRows(at: [indexPath], with: .none)
        })
        tableView.endUpdates()
*/

        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
}


extension MenuViewController {


    func addToOrder(_ indexPath: IndexPath) {
        if let menuItem = restaurant.menus[menuIndex].items?[indexPath.row] {
            let itemName = menuItem.title
            order.addItem(name: itemName, quantity: 1, price: menuItem.price)
            orderSummaryCount.text = String(order.totalNrOfItemsInOrder)

            self.orderSummaryConstraint.constant = self.order.totalNrOfItemsInOrder <= 0 ? -80 : 24
            UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }


    func removeFromOrder(_ indexPath: IndexPath) {
        if let menuItem = restaurant.menus[menuIndex].items?[indexPath.row] {
            let itemName = menuItem.title
            _ = order.removeItem(name: itemName, quantity: 1)
            orderSummaryCount.text = String(self.order.totalNrOfItemsInOrder)

            self.orderSummaryConstraint.constant = self.order.totalNrOfItemsInOrder <= 0 ? -80 : 24
            UIView.animate(withDuration: 0.5, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }

    func clearOrder() {
        order = Order(category: .RoomService)
        expandedCells = []
        orderSummaryConstraint.constant = -80
        self.view.layoutIfNeeded()
        tableView.reloadData()
    }
}

