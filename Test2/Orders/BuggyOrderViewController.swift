//
//  BuggyOrderViewController.swift
//  Test2
//
//  Created by maciulek on 27/02/2022.
//

import UIKit

class BuggyOrderViewController: UIViewController {

    var order: Order = Order(category: .Buggy)

    @IBOutlet weak var sendButton: GlossyButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var roomNumberTextField: UITextField!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var backgroundPicture: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    var category: Order.Category = .Buggy
    var locationPicture = UIImage()
    var completionHandler: (() -> Void)?

    @IBAction func sendButtonPressed(_ sender: UIButton) {
        guard let roomNumber = Int(roomNumberTextField.text ?? ""), roomNumber > 0 else {
            showInfoDialogBox(vc: self, title: "Room Number", message: "Room number is missing")
            return
        }
        let orderNumber = phoneUser.orders.isEmpty ? 1 : phoneUser.orders.first!.number + 1
        if segmentedControl.selectedSegmentIndex == Order.BuggyData.LocationType.Photo.rawValue &&  backgroundPicture.image?.size.width != 0 {
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
        order.setCreated(orderNumber: orderNumber, roomNumber: roomNumber)
        if let comment = commentTextView.text, !comment.isEmpty {
            order.guestComment = comment
        }

        let locationType = Order.BuggyData.LocationType(rawValue: segmentedControl.selectedSegmentIndex) ?? .Room
        var locationData = ""
        switch locationType {
        case .Room: break
        //case .GPS: locationData = "9.583716,100.078701"
        //case .GPS: locationData = String(guest.currentLocationLatitude) + "," + String(guest.currentLocationLongitude)
        case .GPS: locationData = String(0.0) + "," + String(0.0)   // TODO
        case .Other: break
        case .Photo: locationData = photoURL
        }

        order.buggyData = Order.BuggyData(locationType: locationType, locationData: locationData)

        let orderInDB = OrderInDB(order: order, roomNumber: roomNumber)
        let errStr = dbProxy.addRecord(record: orderInDB) { record in
            if record == nil {
                showInfoDialogBox(vc: self, title: "Error", message: "Order update failed")
            } else {

                    DispatchQueue.main.async {
                        self.completionHandler?()
                        let notificationId = String(self.order.roomNumber) + "_" + String(self.order.number)
                        prepareNotification(id: notificationId, title: .order.localizedUppercase, subtitle: String(self.order.number), body: .created.localizedCapitalized, attachmentFile: "RoomService")
                        if let tabBarController = self.tabBarController {
                            self.navigationController?.popToRootViewController(animated: false)
                            tabBarController.selectedIndex = 4
                        }
                    }

            }
        }
        if errStr != nil { Log.log(errStr!) }
    }
    
    @IBAction func segmentedIndexChanged(_ sender: UISegmentedControl) {
        let locationType = Order.BuggyData.LocationType(rawValue: sender.selectedSegmentIndex)
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
        tabBarController?.tabBar.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil) //object: self.view.window)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil) //object: self.view.window)

        let t = UITapGestureRecognizer(target: self, action: #selector(clearKeyboard))
        view.addGestureRecognizer(t)
        t.cancelsTouchesInView = false

        roomNumberTextField.keyboardType = .numberPad
        if !phoneUser.isStaff { roomNumberTextField.text = String(phoneUser.guest?.roomNumber ?? 0) }
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

}




extension BuggyOrderViewController {
    @objc func photoPressed(sender: UIView) {
        guard segmentedControl.selectedSegmentIndex == Order.BuggyData.LocationType.Photo.rawValue else { return }
        let photoSourceRequestController = UIAlertController(title: "", message: NSLocalizedString("Choose your photo source", comment: "Choose your photo source"), preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: NSLocalizedString("Camera", comment: "Camera"), style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .camera
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
        let photoLibraryAction = UIAlertAction(title: NSLocalizedString("Photo library", comment: "Photo library"), style: .default, handler: { (action) in
                if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                    let imagePicker = UIImagePickerController()
                    imagePicker.allowsEditing = false
                    imagePicker.sourceType = .photoLibrary
//                    imagePicker.sourceType = .savedPhotosAlbum
                    imagePicker.delegate = self
                    self.present(imagePicker, animated: true, completion: nil)
                }
            })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
/*
            // For iPad
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
*/
        present(photoSourceRequestController, animated: true, completion: nil)
    }
}


extension BuggyOrderViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
/*
                photoImageView.image = selectedImage
                photoImageView.contentMode = .scaleAspectFill
                photoImageView.clipsToBounds = true
                photoUpdated = true
*/
                locationPicture = selectedImage
                backgroundPicture.image = locationPicture
            }
        dismiss(animated: true, completion: nil)
    }
}
