//
//  RoomViewController.swift
//  Bibzzy
//
//  Created by maciulek on 26/04/2021.
//

import UIKit

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var order = Order(roomNumber: guest.roomNumber, description: "Room Items")

    @IBOutlet weak var orderSummaryConstraint: NSLayoutConstraint!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var orderShortSummaryView: OrderShortSummaryView!

    struct DisplayData {
        var expanded: Bool = false
    }
    lazy var dd = Array(repeating: Array(repeating: DisplayData(), count: 100), count: hotel.roomItems.count)
    
    var observer: NSKeyValueObservation?

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
        tableView.dataSource = self
        tableView.delegate = self

        tableView.backgroundColor = .BBbackgroundColor
        tableView.backgroundColor = UIColor.offWhite
        tableView.allowsSelection = true

        let nib = UINib(nibName: "MenuSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "HeaderTableView")

        orderShortSummaryView.isHidden = true
        //orderSummaryConstraint.constant = 0
        orderShortSummaryView.proceedClosure = {
            let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateOrder") as! CreateOrderViewController
            vc.order = self.order
            vc.completionHandler = { self.clearOrder() }
            self.pushOrPresent(viewController: vc)
        }

        clearOrder()
        
        view.backgroundColor = .lightGray

        // observe changes to the navigation bar size and set different title
        self.observer = self.navigationController?.navigationBar.observe(\.bounds, options: [.new], changeHandler: { (navigationBar, changes) in
                let heightForCollapsedNav = UINavigationController().navigationBar.frame.size.height
                if let height = changes.newValue?.height {
                    self.navigationItem.title = height > heightForCollapsedNav ? "Room \(guest.roomNumber)" : "Room \(guest.roomNumber) - \(guest.Name)"
                }
            })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
        
        tabBarController?.tabBar.isHidden = false
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        let count = 1 + hotel.roomItems.count
        return count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 3 }
        let itemType = RoomItemType.fromInt(section - 1)
        if let itemsInSection = hotel.roomItems[itemType] {
            return itemsInSection.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RoomHeaderCell", for: indexPath) as! RoomHeaderCell
                cell.display(row: indexPath.row)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RoomHeaderCell2", for: indexPath) as! RoomHeaderCell2
                cell.tapClosure = { category in self.maintenancePressed(category: category) }
                cell.display()
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "RoomItemsHeaderCell", for: indexPath) as! RoomItemsHeaderCell
                cell.display()
                return cell
            }
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "RoomItemCell", for: indexPath) as! RoomItemCell
        
        let itemType = RoomItemType.fromInt(indexPath.section - 1)
        guard let item = hotel.roomItems[itemType]?[indexPath.row] else { return cell }

        var expanded = dd[indexPath.section - 1][indexPath.row].expanded
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
        if indexPath.section == 0 {
            switch indexPath.row {
                case 0: inRoomDiningPressed()
                default: break
            }
        } else {
            dd[indexPath.section - 1][indexPath.row].expanded.toggle()
            tableView.reloadRows(at: [indexPath], with: .none)
        }
    }

    func inRoomDiningPressed() {
        let storyboard = UIStoryboard(name: "Menu", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        vc.restaurant = hotel.roomService
        vc.isRoomService = true
        if let nc = self.navigationController {
            nc.pushViewController(vc, animated: true)
        }
        else {
            self.present(vc, animated: true, completion: nil)
        }
    }
/*
    func maintenancePressed(category: RoomItemType) {
        order = Order(roomNumber: guest.roomNumber, description: description)
        let item = RoomItem()
        item.category = category
        item.name = category.rawValue
        order.addItem(name: item.name, quantity: 1, price: 0)
        let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MaintenanceOrder") as! MaintenanceOrderViewController
        vc.order = self.order
        vc.requestType = category
        vc.completionHandler = { self.clearOrder() }
        self.pushOrPresent(viewController: vc)
    }
*/
    func maintenancePressed(category: RoomItemType) {
        let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "MaintenanceOrder") as! MaintenanceOrderViewController
        //vc.order = self.order
        vc.requestType = category
        vc.completionHandler = { self.clearOrder() }
        self.pushOrPresent(viewController: vc)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        if section == 1 { return 30 }
        return 49
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 { return nil }
        let itemType = RoomItemType.fromInt(section)
        return itemType.rawValue
    }
}

extension RoomViewController {

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
        let itemType = RoomItemType.fromInt(indexPath.section - 1)
        if let item = hotel.roomItems[itemType]?[indexPath.row] {
            order.addItem(name: item.name, quantity: 1, price: 0)
        }
        orderShortSummaryView.quantityLabel.text = String(order.totalNrOfItemsInOrder)
        if orderShortSummaryView.isHidden {
            UIView.animate(withDuration: 0.5) { () -> Void in
                self.orderShortSummaryView.isHidden = false
            }
        }
    }

    func removeFromOrder(_ indexPath: IndexPath) {
        let itemType = RoomItemType.fromInt(indexPath.section - 1)
        if let item = hotel.roomItems[itemType]?[indexPath.row] {
            _ = order.removeItem(name: item.name, quantity: 1)
        }
        orderShortSummaryView.quantityLabel.text = String(order.totalNrOfItemsInOrder)
        if order.totalNrOfItemsInOrder <= 0 {
            if !orderShortSummaryView.isHidden {
                UIView.animate(withDuration: 0.5) { () -> Void in
                    self.orderShortSummaryView.isHidden = true
                }
            }
        }
    }

    func clearOrder() {
        order = Order(roomNumber: guest.roomNumber, description: "Room items")
        dd = Array(repeating: Array(repeating: DisplayData(), count: 100), count: hotel.roomItems.count)
        orderShortSummaryView.isHidden = true
        //orderSummaryConstraint.constant = 0
        tableView.reloadData()
    }
}






class RoomHeaderCell: UITableViewCell {

    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var headerImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func display(row: Int) {
        switch row {
        case 0:
            headerTitleLabel.text = "In-room dining"
            headerLabel.text = "Try delicious food from our vast selection of the in-room dining. Delivered right to your door 24/7"
            headerImage.image = UIImage(named: "RoomServiceLarge")
        default:
            break
        }

    }
}


class RoomItemsHeaderCell: UITableViewCell {
    @IBOutlet private weak var headerTitleLabel: UILabel!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var headerImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
    }

    func display() {
//        headerTitleLabel.text = "In-room dining"
//        headerLabel.text = "Try delicious food from our vast selection of the in-room dining, delivered right to your door.\nAvailable 24/7"
//        headerImage.image = UIImage(named: "roomService")
    }
}

class RoomHeaderCell2: UITableViewCell {
    @IBOutlet private weak var headerTitleLabel1: UILabel!
    @IBOutlet private weak var headerLabel1: UILabel!
    @IBOutlet private weak var headerImage1: UIImageView!
    @IBOutlet private weak var headerTitleLabel2: UILabel!
    @IBOutlet private weak var headerLabel2: UILabel!
    @IBOutlet private weak var headerImage2: UIImageView!
    var tapClosure: ((_ category: RoomItemType) -> ())? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none

        let tap1 = UITapGestureRecognizer(target: self, action: #selector(didTap1))
        //tap1.numberOfTapsRequired = 1
        headerImage1.addGestureRecognizer(tap1)
        headerImage1.isUserInteractionEnabled = true

        let tap2 = UITapGestureRecognizer(target: self, action: #selector(didTap2))
        //tap2.numberOfTapsRequired = 1
        headerImage2.addGestureRecognizer(tap2)
        headerImage2.isUserInteractionEnabled = true
    }

    @objc func didTap1() {
        tapClosure?(RoomItemType.Maintenance)
    }

    @objc func didTap2() {
        tapClosure?(RoomItemType.Cleaning)
    }

    func display() {
        headerTitleLabel1.text = "Maintenance"
        headerLabel1.text = "Request a repair"
        headerImage1.image = UIImage(named: "MaintenanceLarge")
        headerTitleLabel2.text = "Cleaning"
        headerLabel2.text = "Ask for extra cleaning"
        headerImage2.image = UIImage(named: "CleaningServiceLarge")
    }
}
