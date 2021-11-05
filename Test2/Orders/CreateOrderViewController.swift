//
//  CreateOrderViewController.swift
//  Test2
//
//  Created by maciulek on 14/05/2021.
//

import UIKit
import IBPCollectionViewCompositionalLayout

class CreateOrderViewController: UIViewController, UITableViewDataSource {

    var order: Order = Order(roomNumber: 0, category: .None)

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var orderSummaryLabel: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var roomNumberStackView: UIStackView!
    @IBOutlet weak var categoryImageView: UIImageView!

    var completionHandler: (() -> Void)?

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        // if admin then room number must be provided
        let roomNumber = Int(roomNumberTextField.text ?? "")
        guard roomNumber != nil || !guest.isAdmin() else {
            showInfoDialogBox(vc: self, title: "Room Number", message: "Room number is missing")
            return
        }

        var orderNumber = guest.orders.isEmpty ? 1 : guest.orders.first!.number + 1
        if guest.isAdmin() {
            // filter orders for the specified room number to get the next order number
            let guestOrders = guest.orders.filter( {$0.roomNumber == roomNumber} )
            orderNumber = guestOrders.isEmpty ? 1 : guestOrders.first!.number + 1
        }

        order.setCreated(orderNumber: orderNumber)
        if let comment = commentField.text, !comment.isEmpty {
            order.guestComment = comment
        }

        let orderInDB = OrderInDB(order: order, roomNumber: roomNumber)
        let errStr = FireB.shared.addRecord(record: orderInDB) { record in
            if record == nil {
                DispatchQueue.main.async {
                    showInfoDialogBox(vc: self, title: "Error", message: "Order update failed")
                }
            } else {
                DispatchQueue.main.async {
                    self.completionHandler?()
                    let notificationId = String(self.order.roomNumber) + "_" + String(self.order.number)
                    prepareNotification(id: notificationId, title: "ORDER", subtitle: String(self.order.number), body: "Your order has been registered!", attachmentFile: "roomOrder")
                    if let tabBarController = self.tabBarController {
                        self.navigationController?.popToRootViewController(animated: false)
                        tabBarController.selectedIndex = 4
                    }
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.sendButton.isEnabled = true
            }
        }
        if errStr != nil {
            Log.log(level: .ERROR, errStr!)
            showInfoDialogBox(vc: self, title: "Error", message: "Updating order failed")
        }
        else {
            activityIndicator.startAnimating()
            sendButton.isEnabled = false
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .singleLine

        tabBarController?.tabBar.isHidden = true
        activityIndicator.hidesWhenStopped = true

        title = "New order"
        categoryImageView.image = UIImage(named: order.category.rawValue)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        tableView.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberTextField.isEnabled = guest.isAdmin()
        roomNumberTextField.keyboardType = .numberPad
        if !guest.isAdmin() { roomNumberTextField.text = String(guest.roomNumber) }
    }

    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
        navigationController?.hidesBarsOnSwipe = false
    }

    @objc func keyboardWillShow(sender: NSNotification) {
        let i = sender.userInfo!
        let k = (i[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        let s = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = k - view.safeAreaInsets.bottom
        UIView.animate(withDuration: s, animations: {self.view.layoutIfNeeded()}) {_ in
            self.tableView.scrollToBottom()
            self.tableView.layoutIfNeeded()
        }
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        let info = sender.userInfo!
        let s: TimeInterval = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = 0
        UIView.animate(withDuration: s) { self.view.layoutIfNeeded() }
    }

    @objc func clearKeyboard() {
        view.endEditing(true)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return order.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! CreateOrderItemCell
        cell.draw(item: order.items[indexPath.row])
        return cell
    }
}

class CreateOrderItemCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func draw(item: Order.OrderItem) {
        itemLabel.text = item.name
        priceLabel.text = item.price > 0.0 ? String(format: "$%.02f", item.price) : ""
        countLabel.text = String(item.quantity)
    }
}
