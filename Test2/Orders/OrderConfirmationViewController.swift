//
//  OrderConfirmationViewController.swift
//  Test2
//
//  Created by maciulek on 04/08/2022.
//

import UIKit
import SwiftUI

class OrderConfirmationViewController: UIViewController, UITableViewDataSource {
    var order: Order6 = Order6(category: .RoomItems)

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    var completionHandler: ((Order6, Bool) -> Void)? = nil

    enum Sections: Int, CaseIterable {
        case header
        case room
        case food
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = .BBseparatorColor
/*
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        tableView.addGestureRecognizer(t)
        t.cancelsTouchesInView = false
*/

//        roomNumberLabel.text = .room
//        roomNumberTextField.isEnabled = phoneUser.isStaff
//        roomNumberTextField.keyboardType = .numberPad
//        roomNumberTextField.text = phoneUser.roomNumber?.toString

        //commentField.placeholder = .comment
        

         let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        sendButton.setTitle(.send, for: .normal)
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupListNavigationBar(largeTitle: false)
        title = .newOrder
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            self.completionHandler?(self.order, true)
        }
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch Sections(rawValue: section) {
        case .header: return 1
        case .room: return order.roomItems.count
        case .food: return order.foodItems.count
        default : return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .header:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell", for: indexPath) as? OrderConfirmationHeaderCell {
                cell.configure(order: order)
                cell.roomNumberTextField.delegate = self
                cell.commentTextView.delegate = self
                return cell
            }
        case .room:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "RoomItemCell", for: indexPath) as? OrderConfirmationRoomItemCell {
                cell.configure(item: order.roomItems[indexPath.row])
                return cell
            }
        case .food:
            if let cell = tableView.dequeueReusableCell(withIdentifier: "FoodItemCell", for: indexPath) as? OrderConfirmationFoodItemCell {
                cell.configure(item: order.foodItems[indexPath.row])
                return cell
            }
        default : break
        }
        return UITableViewCell()
    }
}

extension OrderConfirmationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .normal, title: "Edit") { [weak self] action, view, completionHandler in
            //let menuItem = menus[menuIndex].items[indexPath.row]
            let vc = self?.pushViewController(storyBoard: "Menu", id: "MenuItem2") as! MenuItem2ViewController
            vc.foodOrder = self?.order.foodItems[indexPath.row]
            vc.completionHandler = { [weak self] foodOrderItem in
                self?.order.foodItems[indexPath.row] = foodOrderItem
                DispatchQueue.main.async { self?.tableView.reloadData() }
            }
            completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.order.foodItems.remove(at: indexPath.row)
            DispatchQueue.main.async { self?.tableView.reloadData() }
            completionHandler(true)
        }
        action1.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action1])
    }
}

extension OrderConfirmationViewController: UITextFieldDelegate, UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        order.comment = textView.text
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {
        order.roomNumber = Int(textField.text ?? "") ?? 0
    }
}

extension OrderConfirmationViewController {
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard order.roomNumber > 0 else {
            showInfoDialogBox(title: "Room Number", message: "Room number is missing")
            return
        }

        var orderNumber = phoneUser.orders6.isEmpty ? 1 : phoneUser.orders6.first!.number + 1
        order.number = orderNumber

        if phoneUser.isStaff {
            // filter orders for the specified room number to get the next order number
            let guestOrders = phoneUser.orders6.filter( {$0.roomNumber == order.roomNumber} )
            orderNumber = guestOrders.isEmpty ? 1 : guestOrders.first!.number + 1
        }

        order.setStatus(status: .CREATED(at: Date(), by: phoneUser.displayName))

        let orderInDB = Order6InDB(order: order)
        let errStr = dbProxy.addRecord(record: orderInDB) { [weak self] _, record in
            guard let self = self else { return }
            if record == nil {
                self.showInfoDialogBox(title: "Error", message: "Order update failed")
            } else {
                //self.completionHandler?(self.order, true)
                DispatchQueue.main.async {
                    let notificationId = String(self.order.roomNumber) + "_" + String(self.order.number)
                    prepareNotification(id: notificationId, title: .order.localizedUppercase, subtitle: String(self.order.number), body: .created.localizedCapitalized, attachmentFile: "RoomService")
                    if let tabBarController = self.tabBarController {
                        self.navigationController?.popToRootViewController(animated: false)
                        tabBarController.selectedIndex = 3
                    }
                }
            }
        }
        if errStr != nil { Log.log(errStr!) }
    }
}

class OrderConfirmationHeaderCell: UITableViewCell {
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var categoryImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        roomNumberTextField.keyboardType = .numberPad
        categoryImageView.layer.cornerRadius = categoryImageView.bounds.width/2
        categoryImageView.layer.masksToBounds = true
    }

    func configure(order: Order6) {
        roomNumberTextField.isEnabled = phoneUser.isStaff
        roomNumberTextField.text = phoneUser.roomNumber?.toString
        if order.roomNumber > 0 {
            roomNumberTextField.text = String(order.roomNumber)
        }
        commentTextView.text = order.comment
        categoryImageView.image = UIImage(named: order.category.rawValue)
    }
}

class OrderConfirmationRoomItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        picture.layer.cornerRadius = 8
        picture.layer.masksToBounds = true
    }

    func configure(item: RoomOrderItem) {
        titleLabel.text = item.item.name
        quantityLabel.text = String(item.quantity)
        picture.image = UIImage(named: item.item.picture)
        if let hexColor = Int(item.item.color, radix: 16) {
            picture.backgroundColor = UIColor(hexColor)
        } else {
            picture.backgroundColor = .gray
        }
    }
}

class OrderConfirmationFoodItemCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var picture: UIImageView!
    @IBOutlet weak var choiceLabel: UILabel!
    @IBOutlet weak var addonsLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        backgroundColor = .clear
        picture.layer.cornerRadius = 8
        picture.layer.masksToBounds = true
    }

    func configure(item: FoodOrderItem) {
        titleLabel.text = item.item.title
        quantityLabel.text = String(item.quantity)
        priceLabel.text = String(item.totalPrice)
        //picture.image = UIImage(named: "foodPlaceholder")
        if let img = item.item.img {
            picture.image = UIImage(named: img)
        }
        choiceLabel.text = ""
        choiceLabel.isHidden = item.choiceIndex == nil
        if let choiceIndex = item.choiceIndex {
            choiceLabel.text = item.item.choices?[choiceIndex].title
        }
        addonsLabel.text = ""
        addonsLabel.isHidden = item.addonCount == nil
        if let addonCount = item.addonCount {
            var printNewline = false
            for i in 0...addonCount.count - 1 {
                let count = addonCount[i]
                let title = item.item.addons?[i].title ?? ""
                if count > 0 {
                    if printNewline { addonsLabel.text?.append("\n") }
                    addonsLabel.text?.append("\(count)  \(title)")
                    printNewline = true
                }
            }
        }
    }
}
