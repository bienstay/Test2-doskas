//
//  RoomItemsViewController.swift
//  Test2
//
//  Created by maciulek on 02/11/2021.
//

import UIKit


class OrderShortSummaryView: GlossyView {
//class OrderShortSummaryView: UIView {
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var proceedButton: UIButton!
    private var proceedClosure: (() -> ())? = nil
    @IBAction func proceedPressed(_ sender: UIButton) {
        proceedClosure?()
    }
    func setup(proceedClosure: @escaping () -> ()) {
        self.proceedClosure = proceedClosure
    }
    func configure(quantity: Int) {
        quantityLabel.text = String(quantity)
        proceedButton.setTitle(.proceed, for: .normal)
        proceedButton.layer.cornerRadius = 5
    }
}


class RoomItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var order = Order(roomNumber: guest.roomNumber, category: .RoomItems)

    @IBOutlet weak var orderShortSummaryView: OrderShortSummaryView!
    @IBOutlet weak var orderSummaryConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!

    var expandedCells: Set<IndexPath> = []

    var observer: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self

        title = "Room \(guest.roomNumber)"

        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: UIScreen.main.bounds.height/4)

        orderShortSummaryView.layer.cornerRadius = 20
        orderSummaryConstraint.constant = -80
        orderShortSummaryView.setup {
            let vc = self.pushViewController(storyBoard: "OrderSummary", id: "CreateOrder") as! CreateOrderViewController
            vc.order = self.order
            vc.completionHandler = { self.clearOrder() }
        }

        clearOrder()
/*
        // observe changes to the navigation bar size and set different title
        self.observer = self.navigationController?.navigationBar.observe(\.bounds, options: [.new], changeHandler: { (navigationBar, changes) in
                let heightForCollapsedNav = UINavigationController().navigationBar.frame.size.height
                if let height = changes.newValue?.height {
                    self.navigationItem.title = height > heightForCollapsedNav ? "Room \(guest.roomNumber)" : "Room \(guest.roomNumber) - \(guest.Name)"
                }
            })
 */
        navigationItem.title = .room + " \(guest.roomNumber) - \(guest.Name)"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        let count = hotel.roomItems.count
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let itemType = RoomItem.ItemType.allCases[section]
        if let itemsInSection = hotel.roomItems[itemType] {
            return itemsInSection.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomItemCell", for: indexPath) as! RoomItemCell
        let itemType = RoomItem.ItemType.allCases[indexPath.section]
        guard let item = hotel.roomItems[itemType]?[indexPath.row] else { return cell }

        var expanded = expandedCells.contains(indexPath)
        if let quantity = order.getItem(byString: item.name)?.quantity, quantity > 0 { expanded = true }

        cell.display(roomItem: item, order: order, expanded: expanded)

        cell.buttonTappedClosure = { (cell, add) in
            if (add) { self.addToOrder(indexPath) }
            else { self.removeFromOrder(indexPath)}
//            self.tableView.beginUpdates()
//            self.tableView.reloadRows(at: [indexPath], with: .none)
//            tableView.setNeedsLayout()
//            self.tableView.endUpdates()
            tableView.reloadData()
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if expandedCells.contains(indexPath) { expandedCells.remove(indexPath) }
        else { expandedCells.insert(indexPath) }
        tableView.reloadRows(at: [indexPath], with: .none)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 29
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let itemType = RoomItem.ItemType.allCases[section]
        return itemType.toString()
    }
}

extension RoomItemsViewController {

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        addToOrder(indexPath)
        tableView.reloadRows(at: [indexPath], with: .right)
        return nil
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        removeFromOrder(indexPath)
        tableView.reloadRows(at: [indexPath], with: .left)
        return nil
    }

    func addToOrder(_ indexPath: IndexPath) {
        let itemType = RoomItem.ItemType.allCases[indexPath.section]
        if let item = hotel.roomItems[itemType]?[indexPath.row] {
            order.addItem(name: item.name, quantity: 1, price: 0)
        }
        self.orderShortSummaryView.configure(quantity: self.order.totalNrOfItemsInOrder)

        self.orderSummaryConstraint.constant = self.order.totalNrOfItemsInOrder <= 0 ? -80 : 24
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func removeFromOrder(_ indexPath: IndexPath) {
        let itemType = RoomItem.ItemType.allCases[indexPath.section]
        if let item = hotel.roomItems[itemType]?[indexPath.row] {
            _ = order.removeItem(name: item.name, quantity: 1)
        }
        orderShortSummaryView.configure(quantity: order.totalNrOfItemsInOrder)

        self.orderSummaryConstraint.constant = self.order.totalNrOfItemsInOrder <= 0 ? -80 : 24
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
        })
    }

    func clearOrder() {
        order = Order(roomNumber: guest.roomNumber, category: .RoomItems)
        expandedCells = []
        orderSummaryConstraint.constant = -80
        self.view.layoutIfNeeded()
        tableView.reloadData()
    }
}

