//
//  CreateOrderViewController.swift
//  Test2
//
//  Created by maciulek on 14/05/2021.
//

import UIKit
import IBPCollectionViewCompositionalLayout

class RoomItemsOrderViewController: UIViewController, UITableViewDataSource {
    var order: Order6 = Order6(category: .RoomItems)

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var orderSummaryLabel: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var roomNumberStackView: UIStackView!
    @IBOutlet weak var categoryImageView: UIImageView!

    var completionHandler: (() -> Void)?

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let roomNumber = Int(roomNumberTextField.text ?? ""), roomNumber > 0 else {
            showInfoDialogBox(title: "Room Number", message: "Room number is missing")
            return
        }

        var orderNumber = phoneUser.orders6.isEmpty ? 1 : phoneUser.orders6.first!.number + 1
        if phoneUser.isStaff {
            // filter orders for the specified room number to get the next order number
            let guestOrders = phoneUser.orders6.filter( {$0.roomNumber == roomNumber} )
            orderNumber = guestOrders.isEmpty ? 1 : guestOrders.first!.number + 1
        }

        //order.setCreated(orderNumber: orderNumber, roomNumber: roomNumber)
        order.setStatus(status: .CREATED(at: Date(), by: phoneUser.displayName))
        order.number = orderNumber
        order.roomNumber = roomNumber
        if let comment = commentField.text, !comment.isEmpty {
            order.comment = comment
        }

        let orderInDB = Order6InDB(order: order)
        let errStr = dbProxy.addRecord(record: orderInDB) { _, record in
            if record == nil {
                DispatchQueue.main.async {
                    self.showInfoDialogBox(title: "Error", message: "Order update failed")
                }
            } else {
                DispatchQueue.main.async {
                    self.completionHandler?()
                    let notificationId = String(self.order.roomNumber) + "_" + String(self.order.number)
                    prepareNotification(id: notificationId, title: .order.capitalized, subtitle: String(self.order.number), body: .created.capitalized, attachmentFile: "RoomService")
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
            showInfoDialogBox(title: "Error", message: "Updating order failed")
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
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .BBseparatorColor

        //tabBarController?.tabBar.isHidden = true
        activityIndicator.hidesWhenStopped = true

        categoryImageView.image = UIImage(named: order.category.rawValue)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        tableView.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberLabel.text = .room
        roomNumberTextField.isEnabled = phoneUser.isStaff
        roomNumberTextField.keyboardType = .numberPad
        //if !phoneUser.isStaff { roomNumberTextField.text = String(phoneUser.guest?.roomNumber ?? 0) }
        roomNumberTextField.text = phoneUser.roomNumber?.toString

        commentField.placeholder = .comment
        sendButton.setTitle(.send, for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupListNavigationBar(largeTitle: false)
        title = .newOrder
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
        return order.roomItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! CreateOrderItemCell
        cell.draw(item: order.roomItems[indexPath.row], category: order.category)
        return cell
    }
}

class CreateOrderItemCell: UITableViewCell {
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func draw(item: RoomOrderItem, category: OrderCategory) {
        //if let lang = Locale.current.languageCode, let itemList = String.roomItemsList[lang], category == .RoomItems {
        if let itemList = String.roomItemsList[phoneUser.lang], category == .RoomItems {
            itemLabel.text = itemList[item.item.name]
        } else {
            itemLabel.text = item.item.name
        }
        priceLabel.text = ""
        countLabel.text = String(item.quantity)
    }
}
