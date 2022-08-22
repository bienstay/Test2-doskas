//
//  NewMenuItemViewController.swift
//  Test2
//
//  Created by maciulek on 08/08/2022.
//

import UIKit

class NewMenuItemViewController: UITableViewController {
    var menuItemToEdit: MenuItem?
    var menuName: String?
    var photoUpdated: Bool = false

    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var titleTextField: RoundedTextField! {
        didSet {
            titleTextField.tag = 0
            titleTextField.becomeFirstResponder()
            titleTextField.delegate = self
        }
    }
    @IBOutlet var priceTextField: RoundedTextField! {
        didSet {
            priceTextField.tag = 1
            priceTextField.delegate = self
        }
    }
    @IBOutlet var textTextView: UITextView! {
        didSet {
            textTextView.tag = 2
            textTextView.layer.cornerRadius = 10.0
            textTextView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let menuItem = menuItemToEdit {  // if ToEdit is not null then we are editing the existing post
            titleTextField.text = menuItem.title
            priceTextField.text = String(menuItem.price)
            textTextView.text = menuItem.text
            if let img = menuItem.img, let url = URL(string: img) {
                photoImageView.kf.setImage(with: url)
            }
            title = menuItem.title
        } else {
            title = "New Menu Item"
        }
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var message: String?
        if menuName == nil { message = NSLocalizedString("Menu name missing", comment: "Menu name missing") } else
        if titleTextField.text == "" { message = NSLocalizedString("Title missing", comment: "Title missing") } else
        if priceTextField.text == "" { message = NSLocalizedString("Price missing", comment: "Price missing") } else
        if textTextView.text == "" { message = NSLocalizedString("Text missing", comment: "Text missing") } else
        if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }

        if let message = message {
            showInfoDialogBox(title: "Oops", message: message)
            return
        }

        var menuItem:MenuItem = menuItemToEdit ?? MenuItem()
        menuItem.title = titleTextField.text ?? ""
        menuItem.price = Double(priceTextField.text ?? "") ?? 0.0
        menuItem.text = textTextView.text ?? ""
//        if let orgRestaurant = restaurantToEdit {
//            restaurant.id = orgRestaurant.id
//        }

        if photoUpdated {
            storageProxy.uploadImage(forLocation: .RESTAURANTS, image: photoImageView.image!, imageName: menuItem.title) { error, photoURL in
                if let photoURL = photoURL, let menuName = self.menuName {
                    menuItem.img = photoURL
                    let errStr = dbProxy.addRecord(key: menuItem.id, subNode: menuName, record: MenuItemInDB(menuItem)) { _, menuItem in self.closeMe(menuItem) }
                    if let s = errStr { Log.log(s) }
                }
            }
        } else {
            let errStr = dbProxy.addRecord(key: menuItem.id, subNode: menuName, record: MenuItemInDB(menuItem)) { _, menuItem in self.closeMe(menuItem) }
            if let s = errStr { Log.log(s) }
        }
    }

    func closeMe(_ menuItem:MenuItemInDB?) {
        guard menuItem != nil else {
            showInfoDialogBox(title: "Error", message: "Menu Item update failed")
            return
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension NewMenuItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension NewMenuItemViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: showImagePicker(nc: self)
        case 3:
//            let vc = pushViewController(storyBoard: "Restaurants", id: "MenuList") as! MenuListViewController
//            vc.restaurant = restaurantToEdit!
//            vc.completionCallback = { [weak self] menuList in
//                self?.restaurantToEdit?.menus = menuList
//                self?.fillMenus()
//                self?.tableView.reloadData()
//            }
            break
        default: break
        }
    }
}

extension NewMenuItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                photoImageView.image = selectedImage
                photoImageView.contentMode = .scaleAspectFill
                photoImageView.clipsToBounds = true
                photoUpdated = true
            }
        dismiss(animated: true, completion: nil)
    }
}

