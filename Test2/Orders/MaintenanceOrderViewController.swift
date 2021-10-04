//
//  MaintenanceOrderViewController.swift
//  Test2
//
//  Created by maciulek on 01/10/2021.
//

import UIKit

class MaintenanceOrderViewController: UIViewController {

    var order: Order = Order(roomNumber: 0, description: "")

    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var orderSummaryLabel: UILabel!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var commentTextView: UITextView!
//    @IBOutlet weak var roomNumberStackView: UIStackView!

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
        if let comment = commentTextView.text, !comment.isEmpty {
            order.guestComment = comment
        }

        let orderInDB = OrderInDB(order: order, roomNumber: roomNumber)
        let errStr = FireB.shared.addRecord(record: orderInDB) { record in
            if record == nil {
                showInfoDialogBox(vc: self, title: "Error", message: "Order update failed")
            } else {
                //showInfoDialogBox(vc: self, title: "Info", message: "Order \(record!.number) created")
                
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
        }
        if errStr != nil { Log.log(errStr!) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        tabBarController?.tabBar.isHidden = true

        title = "New request"

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberTextField.isEnabled = guest.isAdmin()
        roomNumberTextField.keyboardType = .numberPad
        if !guest.isAdmin() { roomNumberTextField.text = String(guest.roomNumber) }
        
        commentTextView.becomeFirstResponder()
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
        //let s = (i[UIResponder.keyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        bottomConstraint.constant = k - view.safeAreaInsets.bottom
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

}
