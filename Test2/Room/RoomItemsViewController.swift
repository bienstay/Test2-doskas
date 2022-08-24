//
//  RoomItemsViewController.swift
//  Test2
//
//  Created by maciulek on 02/11/2021.
//

import UIKit


//class OrderShortSummaryView: GlossyView {
class OrderShortSummaryView: UIView {
    @IBOutlet private weak var quantityLabel: UILabel!
    @IBOutlet private weak var proceedButton: UIButton!

    private var proceedClosure: (() -> ())? = nil
    @IBAction func proceedPressed(_ sender: UIButton) {
        proceedClosure?()
    }
    func setup(proceedClosureParam: @escaping () -> ()) {
        proceedClosure = proceedClosureParam
        let sidePadding: CGFloat = 8.0
        //proceedButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -sidePadding, bottom: 0.0, right: -sidePadding)
        proceedButton.contentEdgeInsets = UIEdgeInsets(top: 0.0, left: sidePadding, bottom: 0.0, right: sidePadding)
    }
    func configure(quantity: Int) {
        backgroundColor = .BBreversedCellColor
        quantityLabel.textColor = .BBreversedTextColor
        proceedButton.backgroundColor = .BBreversedCellColor
        proceedButton.setTitleColor(.BBreversedTextColor, for: .normal)
        quantityLabel.text = String(quantity)
        proceedButton.setTitle(.proceed, for: .normal)
        proceedButton.layer.cornerRadius = 5
    }
}


class RoomItemsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var order = Order6(category: .RoomItems)

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

        //title = phoneUser.isStaff ? "Room \(phoneUser.guest?.roomNumber)" : phoneUser.user?.name
        title = phoneUser.displayName

        tableView.tableHeaderView?.frame.size = CGSize(width: tableView.frame.width, height: UIScreen.main.bounds.height/4)

        orderShortSummaryView.layer.cornerRadius = 20
        orderSummaryConstraint.constant = -80
        orderShortSummaryView.setup { [weak self] in
            guard let self = self else { return }
            if let vc = self.pushViewController(storyBoard: "OrderSummary", id: "OrderConfirmation") as? OrderConfirmationViewController {
                vc.order = self.order
                //vc.completionHandler = { [weak self] order, _ in self?.clearOrder() }
            }
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
        //navigationItem.title = .room + " \(guest.roomNumber) - \(guest.Name)"
        navigationItem.title = phoneUser.displayName
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
        if let quantity = order.roomItems.first(where: { $0.item.name == item.name })?.quantity, quantity > 0 { expanded = true }

        cell.display(roomItem: item, order: order, expanded: expanded)

        cell.buttonTappedClosure = { [weak self] addd in
            guard let self = self else { return }
            if addd { self.addToOrder(indexPath) }
            else { self.removeFromOrder(indexPath)}
            self.tableView.reloadData()
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
            order.addRoomItem(item: item)
        }
        orderShortSummaryView.configure(quantity: order.totalNrOfRoomItems)

        orderSummaryConstraint.constant = order.totalNrOfRoomItems <= 0 ? -80 : 24
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 10, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    func removeFromOrder(_ indexPath: IndexPath) {
        let itemType = RoomItem.ItemType.allCases[indexPath.section]
        if let item = hotel.roomItems[itemType]?[indexPath.row] {
            _ = order.removeRoomItem(item: item)
        }
        orderShortSummaryView.configure(quantity: order.totalNrOfRoomItems)

        orderSummaryConstraint.constant = self.order.totalNrOfRoomItems <= 0 ? -80 : 24
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }

    func clearOrder() {
        order = Order6(category: .RoomItems)
        order.roomNumber = phoneUser.roomNumber ?? 0
        expandedCells = []
        orderSummaryConstraint.constant = -80
        view.layoutIfNeeded()
        tableView.reloadData()
    }
}

