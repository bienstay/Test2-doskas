//
//  TestViewController.swift
//  Test2
//
//  Created by maciulek on 04/05/2021.
//

import UIKit

// MARK: - Main class
class MenuViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // model
    var restaurant: Restaurant?
    var menuIndex = 0
    private var order = Order(roomNumber: guest.roomNumber, description: "In-room dining")
    private var menus: [Menu] = []

    // display
    private var orderEnabled = false
    private var swipeEnabled = false
    private var fadeInEnabled: Bool = false
    var isRoomService = false {
        didSet {
            orderEnabled = isRoomService
            swipeEnabled = isRoomService
            //fadeInEnabled = !isRoomService
        }
    }

    private struct DisplayData {
        var expanded: Bool = false
    }
    private var dd:[[DisplayData]] = []

    @IBOutlet weak var orderSummaryConstraint: NSLayoutConstraint!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var headerLabel: UILabel!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var orderShortSummaryView: OrderShortSummaryView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self

        let nib = UINib(nibName: "MenuSectionHeaderView", bundle: nil)
        tableView.register(nib, forHeaderFooterViewReuseIdentifier: "HeaderTableView")
        
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        orderShortSummaryView.isHidden = true
        orderSummaryConstraint.constant = 1
        orderShortSummaryView.proceedClosure = {
            let storyboard = UIStoryboard(name: "OrderSummary", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "CreateOrder") as! CreateOrderViewController
            vc.order = self.order
            vc.completionHandler = { self.clearOrder() }
            self.pushOrPresent(viewController: vc)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        menus = restaurant?.menus ?? []
        title = restaurant?.name
        if menus.count > 0 { headerLabel.text = menus[menuIndex].title }
        resetDisplayData()
        tabBarController?.tabBar.isHidden = true
    }

    func resetDisplayData() {
        dd = [[]]
        guard menus.count > 0 else { return }
        let sectionCount = menus[menuIndex].sections?.count ?? 0
        dd = [[DisplayData]](repeating: [], count: sectionCount)

        for section in 0...sectionCount-1 {
            let itemCount = menus[menuIndex].sections?[section].items.count ?? 0
            dd[section] = [DisplayData](repeating: DisplayData(), count: itemCount)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        guard menus.count > 0 else { return 0 }
        return menus[menuIndex].sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menus[menuIndex].sections?[section].items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let menuItem = menus[menuIndex].sections?[indexPath.section].items[indexPath.row] {
            if menuItem.itemType == MenuItem.FOODITEM {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuFoodCell", for: indexPath) as! MenuFoodCell
                cell.display(menuItem: menuItem, order: order, expanded: dd[indexPath.section][indexPath.row].expanded, orderEnabled: orderEnabled)
                cell.buttonTappedClosure = { (cell, add) in
                    if add { self.addToOrder(indexPath) }
                    else { self.removeFromOrder(indexPath)}
                    self.tableView.reloadData()
                    //self.tableView.reloadData(completion: {self.fadeInEnabled = true}) // TODO - reload rows is not working right with the fade-in animation
                }
                return cell;
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "MenuGroupCell", for: indexPath) as! MenuGroupCell
                cell.display(menuItem: menuItem)
                return cell
            }
        }
        else {
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if fadeInEnabled {
            // Define the initial state (Before the animation)
            cell.alpha = 0
            // Define the final state (After the animation)
            UIView.animate(withDuration: 1.0, animations: { cell.alpha = 1 })
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dd[indexPath.section][indexPath.row].expanded.toggle()
        tableView.beginUpdates()    // TODO - check if necessary
        tableView.reloadRows(at: [indexPath], with: .automatic)
        tableView.setNeedsLayout()
        tableView.endUpdates()
        //tableView.reloadData()
    }
}




// MARK: - Section header
extension MenuViewController {

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderTableView") as! MenuSectionHeaderView
        //view.addInnerShadow()
        view.sectionHeaderLabel.text = menus[menuIndex].sections?[section].title
        return view
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
      }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
      }
}

class MenuSectionHeaderView: UITableViewHeaderFooterView {
    @IBOutlet weak var sectionHeaderLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        let bgView = UIView(frame: self.bounds)
        bgView.backgroundColor = UIColor(white: 0.5, alpha: 0.0)
        self.backgroundView = bgView
        contentView.layer.cornerRadius = 0
        sectionHeaderLabel.textColor = .gray
    }
}




extension MenuViewController {

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if swipeEnabled {
            addToOrder(indexPath)
            tableView.reloadRows(at: [indexPath], with: .right)
        }
        return nil
    }

    // TODO - separate model from view
    func addToOrder(_ indexPath: IndexPath) {
        if let menuItem = menus[menuIndex].sections?[indexPath.section].items[indexPath.row] {
            let itemName = menuItem.title
            order.addItem(name: itemName, quantity: 1, price: menuItem.price)
            orderShortSummaryView.quantityLabel.text = String(order.totalNrOfItemsInOrder)
            orderShortSummaryView.isHidden = order.totalNrOfItemsInOrder <= 0
            orderSummaryConstraint.constant = order.totalNrOfItemsInOrder <= 0 ? 1 : 100
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if swipeEnabled {
            removeFromOrder(indexPath)
            tableView.reloadRows(at: [indexPath], with: .left)
        }
        return nil
    }

    func removeFromOrder(_ indexPath: IndexPath) {
        if let menuItem = menus[menuIndex].sections?[indexPath.section].items[indexPath.row] {
            let itemName = menuItem.title
            _ = order.removeItem(name: itemName, quantity: 1)
            orderShortSummaryView.quantityLabel.text = String(self.order.totalNrOfItemsInOrder)
            orderShortSummaryView.isHidden = order.totalNrOfItemsInOrder <= 0
            orderSummaryConstraint.constant = order.totalNrOfItemsInOrder <= 0 ? 1 : 100
        }
    }

    func clearOrder() {
        order = Order(roomNumber: guest.roomNumber, description: "In-room dining")
        dd = Array(repeating: Array(repeating: DisplayData(), count: 100), count: 10)   // TODO
        orderShortSummaryView.isHidden = true
        orderSummaryConstraint.constant = 1
        tableView.reloadData()
    }
}

