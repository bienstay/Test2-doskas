//
//  MaintenanceOrderViewController.swift
//  Test2
//
//  Created by maciulek on 01/10/2021.
//

import UIKit

class ServiceOrderViewController: UIViewController {

    //var order: Order = Order(category: .None)
    //var order: Order2 = Order2()
    var order: Order6 = Order6(category: .None)

    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var backgroundPicture: UIImageView!

    var completionHandler: (() -> Void)?

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let roomNumber = Int(roomNumberTextField.text ?? ""), roomNumber > 0 else {
            showInfoDialogBox(title: "Room Number", message: "Room number is missing")
            return
        }
        order.roomNumber = roomNumber

        var orderNumber = phoneUser.orders6.isEmpty ? 1 : phoneUser.orders6.first!.number + 1
        order.number = orderNumber
        
        if phoneUser.isStaff {
            // filter orders for the specified room number to get the next order number
            let guestOrders = phoneUser.orders6.filter( {$0.roomNumber == roomNumber} )
            orderNumber = guestOrders.isEmpty ? 1 : guestOrders.first!.number + 1
        }

        //order.setCreated(orderNumber: orderNumber, roomNumber: roomNumber)
        order.setStatus(status: .CREATED(at: Date(), by: phoneUser.displayName))
        if let comment = commentTextView.text, !comment.isEmpty {
            //order.guestComment = comment
            order.comment = comment
        }

        //let orderInDB = OrderInDB(order: order, roomNumber: roomNumber)
        //let orderInDB = Order2InDB(order: order)
        let orderInDB = Order6InDB(order: order)
        let errStr = dbProxy.addRecord(record: orderInDB) { _, record in
            if record == nil {
                self.showInfoDialogBox(title: "Error", message: "Order update failed")
            } else {
                DispatchQueue.main.async {
                    self.completionHandler?()
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

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberTextField.text = phoneUser.roomNumber?.toString
        roomNumberTextField.isEnabled = phoneUser.isStaff
        roomNumberTextField.keyboardType = .numberPad

        backgroundPicture.image = UIImage(named: order.category.rawValue)
        //backgroundPicture.image = UIImage(named: order.category.toString())

        commentTextView.layer.borderColor = UIColor.BBseparatorColor.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.becomeFirstResponder()
        sendButton.setTitle(.send, for: .normal)
        commentLabel.text = .description + ":"
        roomNumberLabel.text = .room
    }

    override func viewWillAppear(_ animated: Bool) {
        setupListNavigationBar(largeTitle: false)
        title = order.category.toString()
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
