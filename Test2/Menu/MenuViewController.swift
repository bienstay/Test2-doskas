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
    var menus: [Menu] = []
    var menuIndex = 0
    var order:Order6?

    var expandedCells: Set<Int> = []

    @IBAction func orderSummaryPressed(_ sender: UIButton) {
        guard let order = order else { return }
        let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "OrderConfirmation") as! OrderConfirmationViewController
        vc.order = order
        //vc.completionHandler = { order, _ in self.clearOrder() }
        vc.completionHandler = { [weak self] order, _ in self?.order = order }
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
    @IBOutlet private weak var orderShortSummary2View: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .offWhiteVeryLight
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        orderShortSummaryView.layer.cornerRadius = 20
        orderShortSummary2View.layer.cornerRadius = 20
        orderSummaryConstraint.constant = -80

        orderShortSummaryView.isHidden = true//(order == nil)
        orderShortSummary2View.isHidden = (order == nil)

        for key in restaurant.menus {
            if let menu = hotel.menus[key] {
                menus.append(menu)
            }
        }
        
        if order != nil { clearOrder() }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar()

        navigationItem.title = restaurant.name
        if menus.count > 0 { headerLabel.text = menus[menuIndex].name }
        resetDisplayData()
        
        tableView.alpha = 0
        UIView.animate(withDuration: 0.5, animations: { self.tableView.alpha = 1 })

        orderShortSummaryView.superview?.layoutIfNeeded()
        orderShortSummary2View.superview?.layoutIfNeeded()
    }

    func resetDisplayData() {
        expandedCells = []
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !menus.isEmpty else {return 0}
        return menus[menuIndex].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = menus[menuIndex].items[indexPath.row]
        if menuItem.type == .FOODITEM {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuFoodCell", for: indexPath) as! MenuFoodCell
            cell.display(menuItem: menuItem, order: order, expanded: expandedCells.contains(indexPath.row), orderEnabled: order != nil)
//            cell.buttonTappedClosure = { [weak self] addd in
//                guard let self = self else { return }
//                if addd { self.addToOrder(indexPath) }
//                else { self.removeFromOrder(indexPath)}
//                self.tableView.reloadData()
//            }
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MenuGroupCell", for: indexPath) as! MenuGroupCell
            cell.display(menuItem: menuItem)
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = menus[menuIndex].items[indexPath.row]
        let vc = pushViewController(storyBoard: "Menu", id: "MenuItem2") as! MenuItem2ViewController
        if order != nil {
            vc.foodOrder = FoodOrderItem(item: menuItem)
        } else {
            vc.menuItem = menuItem
        }
        vc.completionHandler = { [weak self] foodOrderItem in
            self?.addToOrder(foodItem: foodOrderItem)
        }
        return

        if expandedCells.contains(indexPath.row) { expandedCells.remove(indexPath.row) }
        else { expandedCells.insert(indexPath.row) }

        tableView.beginUpdates()
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()

        guard let cell = tableView.cellForRow(at: indexPath) as? MenuFoodCell else { return }
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
            cell.display(menuItem: menuItem, order: self.order, expanded: self.expandedCells.contains(indexPath.row), orderEnabled: self.order != nil)
            cell.layoutIfNeeded()
        }, completion: {_ in
//            tableView.layoutIfNeeded()
//                tableView.reloadRows(at: [indexPath], with: .none)
        })
        tableView.endUpdates()


        tableView.scrollToRow(at: indexPath, at: .none, animated: true)
    }
}


extension MenuViewController {


//    func addToOrder(_ indexPath: IndexPath) {
//        guard order != nil else { return }
//        let menuItem = menus[menuIndex].items[indexPath.row]
//        order!.addFoodItem(item: menuItem)
//        orderSummaryCount.text = String(order!.totalNrOfFoodItems)
//
//        self.orderSummaryConstraint.constant = self.order!.totalNrOfFoodItems <= 0 ? -80 : 24
//        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: {
//            self.view.layoutIfNeeded()
//        })
//    }
    func addToOrder(foodItem: FoodOrderItem) {
        order?.addFoodItem(item: foodItem)
        orderSummaryCount.text = String(order!.totalNrOfFoodItems)

        self.orderSummaryConstraint.constant = self.order!.totalNrOfFoodItems <= 0 ? -80 : 24
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func removeFromOrder(foodItem: FoodOrderItem) {
        _ = order!.removeFoodItem(item: foodItem)
        orderSummaryCount.text = String(self.order!.totalNrOfFoodItems)

        self.orderSummaryConstraint.constant = self.order!.totalNrOfFoodItems <= 0 ? -80 : 24
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func clearOrder() {
        order = Order6(category: .RoomService)
        order?.roomNumber = phoneUser.roomNumber ?? 0
        expandedCells = []
        orderSummaryConstraint.constant = -80
        self.view.layoutIfNeeded()
        tableView.reloadData()
    }
}

