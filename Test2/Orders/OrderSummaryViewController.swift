//
//  OrderSummaryViewController.swift
//  Test2
//
//  Created by maciulek on 30/06/2021.
//

import UIKit

class OrderSummaryViewController: UIViewController, UITableViewDataSource {

    var order: Order = Order(roomNumber: 0, category: .None)
    
    enum Sections: Int, CaseIterable {
        case Items = 0
        case GuestComment
    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var entireView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var categoryImage: UIImageView!

    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var timeCreatedLabel: UILabel!
    @IBOutlet weak var roomNumberLabel: UILabel!

    @IBOutlet weak var createdByLabel: UILabel!
    @IBOutlet weak var createdAtLabel: UILabel!
    @IBOutlet weak var canceledByLabel: UILabel!
    @IBOutlet weak var canceledAtLabel: UILabel!
    @IBOutlet weak var canceledStackView: UIStackView!
    @IBOutlet weak var confirmedByLabel: UILabel!
    @IBOutlet weak var confirmedAtLabel: UILabel!
    @IBOutlet weak var confirmedStackView: UIStackView!
    @IBOutlet weak var deliveredByLabel: UILabel!
    @IBOutlet weak var deliveredAtLabel: UILabel!
    @IBOutlet weak var deliveredStackView: UIStackView!

    @IBOutlet weak var statusChangeButton: UIBarButtonItem!
    @IBAction func statusChangeButtonPressed(_ sender: UIBarButtonItem) {
        if order.status == Order.Status.CREATED {
            if guest.isAdmin() {
                FireB.shared.updateOrderStatus(orderId: order.id!, newStatus: .CONFIRMED, confirmedBy: guest.Name)
            } else {
                askToCancel()
            }
        }
        else if order.status == Order.Status.CONFIRMED {
            FireB.shared.updateOrderStatus(orderId: order.id!, newStatus: .DELIVERED, deliveredBy: guest.Name)
        }
    }

    func askToCancel() {
        let cancelAlert = UIAlertController(title: "Cancel", message: "Are you sure you want to cancel this order?", preferredStyle: UIAlertController.Style.alert)
        cancelAlert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive, handler: { (action: UIAlertAction!) in
            FireB.shared.updateOrderStatus(orderId: self.order.id!, newStatus: .CANCELED, canceledBy: String(guest.roomNumber))
        }))
        cancelAlert.addAction(UIAlertAction(title: "Back", style: .cancel, handler: { (action: UIAlertAction!) in
        }))
        present(cancelAlert, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .singleLine

        roomNumberLabel.text = "Room: " + String(order.roomNumber)
        timeCreatedLabel.text = order.created?.formatFriendly()
        idLabel.text = "Order ID: " + order.id!

        categoryImage.image = UIImage(named: order.category.rawValue)

        title = "Order number \(order.number)"
    
        NotificationCenter.default.addObserver(self, selector: #selector(onOrdersUpdated(_:)), name: .ordersUpdated, object: nil)

        let barButton = createBarButtonItem(target: self, action: #selector(statusChangeButtonPressed))
        statusChangeButton = barButton
        self.navigationItem.rightBarButtonItem = barButton
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
        navigationController?.hidesBarsOnSwipe = false
        tableView.contentInsetAdjustmentBehavior = .never
        
        updateStatusLabelsAndButtons()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
            case .Items:
                return order.items.count
        case .GuestComment:
                return 1
            default:
                return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .Items:
            let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! OrderSummaryItemCell
            cell.draw(item: order.items[indexPath.row])
            return cell
        case .GuestComment:
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath)
            cell.contentView.backgroundColor = .clear
            cell.textLabel?.text = order.guestComment
            return cell
            default:
                return UITableViewCell()
        }
    }
    
    func updateStatusLabelsAndButtons() {
        statusLabel.text = order.status.rawValue
        confirmedStackView.isHidden = true
        deliveredStackView.isHidden = true
        canceledStackView.isHidden = true
        switch order.status {
        case .CANCELED:
            canceledAtLabel.text = order.canceled?.formatFriendly()
            canceledByLabel.text = order.canceledBy
            canceledStackView.isHidden = false
            createdAtLabel.text = order.created?.formatFriendly()
            createdByLabel.text = order.createdBy
        case .DELIVERED:
            deliveredAtLabel.text = order.delivered?.formatFriendly()
            deliveredByLabel.text = order.deliveredBy
            deliveredStackView.isHidden = false
            fallthrough
        case .CONFIRMED:
            confirmedAtLabel.text = order.confirmed?.formatFriendly()
            confirmedByLabel.text = order.confirmedBy
            confirmedStackView.isHidden = false
            fallthrough
        case .CREATED:
            createdAtLabel.text = order.created?.formatFriendly()
            createdByLabel.text = order.createdBy
        }

        switch order.status {
        case .CANCELED:
            statusLabel.textColor = .black
        case .DELIVERED:
            statusLabel.textColor = .darkGreen
        case .CONFIRMED:
            statusLabel.textColor = .darkYellow
        case .CREATED:
            statusLabel.textColor = .red
        }

        let button = statusChangeButton.customView as! UIButton
        if guest.isAdmin() {
            button.isHidden = false
            if order.status == Order.Status.CREATED {
                button.setTitle("Confirm", for: .normal)
            }
            else if order.status == Order.Status.CONFIRMED {
                button.setTitle("Close", for: .normal)
            } else {
                button.isHidden = true
                button.setTitle("", for: .normal)
            }
        }
        else {
            let title: String = order.status == Order.Status.CREATED ? "Cancel" : ""
            button.setTitle(title, for: .normal)
            button.isHidden = order.status != Order.Status.CREATED
        }
    }
    
    @objc func onOrdersUpdated(_ notification: Notification) {
        if let or = guest.orders.first(where: { $0.id == order.id }) {
            order = or
        }
        DispatchQueue.main.async { self.updateStatusLabelsAndButtons() }
    }

}

extension OrderSummaryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch Sections(rawValue: section) {
        case .GuestComment:
            if let comment = order.guestComment, !comment.isEmpty { return "Comment" }
            return nil
            default: return nil
        }
    }
}



class OrderSummaryItemCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        //contentView.backgroundColor = .BBbackgroundColor
        //contentView.backgroundColor = .clear
    }
    
    func draw(item: Order.OrderItem) {
        itemLabel.text = item.name
        priceLabel.text = item.price > 0.0 ? String(format: "$%.02f", item.price) : ""
        countLabel.text = String(item.quantity)
    }
}
