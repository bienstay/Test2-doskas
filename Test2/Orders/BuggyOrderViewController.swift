//
//  BuggyOrderViewController.swift
//  Test2
//
//  Created by maciulek on 27/02/2022.
//

import UIKit

class BuggyOrderViewController: UIViewController {

    var order: Order6 = Order6(category: .Buggy)

    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var category: OrderCategory = .Buggy
    var locationPicture = UIImage()
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

        if segmentedControl.selectedSegmentIndex == BuggyOrderItem.LocationType.Photo.rawValue &&  backgroundPicture.image?.size.width != 0 {
            storageProxy.uploadImage(forLocation: .NEWS, image: backgroundPicture.image!, imageName: String(roomNumber) + "_" + String(orderNumber)) { error, photoURL in
                if let photoURL = photoURL {
                    self.finalizeOrderSend(roomNumber: roomNumber, orderNumber: orderNumber, photoURL: photoURL)
                }
            }
        } else {
            finalizeOrderSend(roomNumber: roomNumber, orderNumber: orderNumber, photoURL: "")
        }
    }

    func finalizeOrderSend(roomNumber: Int, orderNumber: Int, photoURL: String) {
        order.setStatus(status: .CREATED(at: Date(), by: phoneUser.displayName))
        order.number = orderNumber
        if let comment = commentTextView.text, !comment.isEmpty {
            order.comment = comment
        }

        let locationType = BuggyOrderItem.LocationType(rawValue: segmentedControl.selectedSegmentIndex) ?? .Room
        var locationData = ""
        switch locationType {
            case .Room: break
            case .GPS: locationData = String(phoneUser.currentLocationLatitude) + "," + String(phoneUser.currentLocationLongitude)
            case .Other: break
            case .Photo: locationData = photoURL
        }

        order.buggyItem = BuggyOrderItem(locationType: locationType, locationData: locationData)

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
    
    @IBAction func segmentedIndexChanged(_ sender: UISegmentedControl) {
        let locationType = BuggyOrderItem.LocationType(rawValue: sender.selectedSegmentIndex)
        switch locationType {
        case .Room:
            backgroundPicture.image = UIImage(named: "Buggy")
        case .GPS:
            backgroundPicture.image = UIImage(named: "Buggy")
        case .Photo:
            backgroundPicture.image = locationPicture
        case .Other:
            backgroundPicture.image = UIImage(named: "Buggy")
        default: break
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        //tabBarController?.tabBar.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberTextField.keyboardType = .numberPad
        //if !phoneUser.isStaff { roomNumberTextField.text = String(phoneUser.guest?.roomNumber ?? 0) }
        roomNumberTextField.text = phoneUser.roomNumber?.toString
        roomNumberTextField.isEnabled = phoneUser.isStaff

        backgroundPicture.image = UIImage(named: category.rawValue)

        commentTextView.layer.borderColor = UIColor.BBseparatorColor.cgColor
        commentTextView.layer.borderWidth = 1
        commentTextView.becomeFirstResponder()
        sendButton.setTitle(.send, for: .normal)
        commentLabel.text = .description + ":"
        roomNumberLabel.text = .room
        
        backgroundPicture.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(photoPressed))
        backgroundPicture.addGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        setupListNavigationBar(largeTitle: false)
        title = category.toString()
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

    @objc func photoPressed(sender: UIView) {
        guard segmentedControl.selectedSegmentIndex == BuggyOrderItem.LocationType.Photo.rawValue else { return }
        showImagePicker(nc: self)
    }
}

extension BuggyOrderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                locationPicture = selectedImage
                backgroundPicture.image = locationPicture
            }
        dismiss(animated: true, completion: nil)
    }
}
