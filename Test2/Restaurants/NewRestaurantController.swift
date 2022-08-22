//
//  NewRestaurantController.swift
//  FoodPin
//
//  Created by maciulek on 04/04/2021.
//

import UIKit

class NewRestaurantController: UITableViewController {
    var restaurantToEdit: Restaurant?
    var photoUpdated: Bool = false

    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }

    @IBOutlet var nameTextField: RoundedTextField! {
        didSet {
            nameTextField.tag = 1
            nameTextField.becomeFirstResponder()
            nameTextField.delegate = self
        }
    }
    @IBOutlet var cuisinesTextField: RoundedTextField! {
        didSet {
            cuisinesTextField.tag = 2
            cuisinesTextField.delegate = self
        }
    }
    @IBOutlet var locationTextField: RoundedTextField! {
        didSet {
            locationTextField.tag = 3
            locationTextField.delegate = self
        }
    }
    @IBOutlet weak var longitudeTextField: RoundedTextField! {
        didSet {
            longitudeTextField.keyboardType = .decimalPad
            longitudeTextField.tag = 4
            longitudeTextField.delegate = self
        }
    }
    @IBOutlet weak var latitudeTextField: RoundedTextField! {
        didSet {
            latitudeTextField.keyboardType = .decimalPad
            latitudeTextField.tag = 5
            latitudeTextField.delegate = self
        }
    }
    @IBOutlet var phoneTextField: RoundedTextField! {
        didSet {
            phoneTextField.tag = 6
            phoneTextField.delegate = self
        }
    }
    @IBOutlet var descriptionTextView: UITextView! {
        didSet {
            descriptionTextView.tag = 7
            descriptionTextView.layer.cornerRadius = 10.0
            descriptionTextView.layer.masksToBounds = true
        }
    }
    @IBOutlet var menusLabel: UILabel! {
        didSet {
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        menusLabel.text = "lsjclkashdclajkdc"

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        
        if let restaurant = restaurantToEdit {  // if restaurantToEdit is not null then we are editing the existing post
            nameTextField.text = restaurant.name
            cuisinesTextField.text = restaurant.cuisines
            descriptionTextView.text = restaurant.description
            phoneTextField.text = restaurant.phone
            locationTextField.text = restaurant.location
            latitudeTextField.text = String(restaurant.geoLatitude)
            longitudeTextField.text = String(restaurant.geoLongitude)
            if let url = URL(string: restaurant.image) {
                photoImageView.kf.setImage(with: url)
            }
            title = restaurant.name
            fillMenus()
        } else {
            title = "New Restaurant"
        }
    }

    private func fillMenus() {
        if let r = restaurantToEdit {
            var s = "\n"
            for m in r.menus {
                s.append(m)
                s.append("\n")
            }
            menusLabel.text = s
        }
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var message: String?
        if nameTextField.text == "" { message = NSLocalizedString("Name missing", comment: "Name missing") } else
        if cuisinesTextField.text == "" { message = NSLocalizedString("Type missing", comment: "Type missing") } else
        if locationTextField.text == "" { message = NSLocalizedString("Location missing", comment: "Location missing") } else
        if descriptionTextView.text == "" { message = NSLocalizedString("Description missing", comment: "Description missing") } else
        if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }
        
        if let message = message {
            showInfoDialogBox(title: "Oops", message: message)
            return
        }

        var restaurant = Restaurant()
        restaurant.name = nameTextField.text ?? ""
        restaurant.cuisines = cuisinesTextField.text ?? ""
        restaurant.description = descriptionTextView.text ?? ""
        restaurant.phone = phoneTextField.text ?? ""

        restaurant.location = locationTextField.text ?? ""
        restaurant.geoLatitude = Double(latitudeTextField.text!) ?? 0.0
        restaurant.geoLongitude = Double(longitudeTextField.text!) ?? 0.0

        restaurant.menus = restaurantToEdit?.menus ?? []

        if let orgRestaurant = restaurantToEdit {
            restaurant.id = orgRestaurant.id
        }

        if photoUpdated {
            storageProxy.uploadImage(forLocation: .RESTAURANTS, image: photoImageView.image!, imageName: restaurant.name) { error, photoURL in
                if let photoURL = photoURL {
                    restaurant.image = photoURL
                    let errStr = dbProxy.addRecord(key: restaurant.id, record: RestaurantInDB(r: restaurant)) { _, restaurant in self.closeMe(restaurant) }
                    if let s = errStr { Log.log(s) }
                }
            }
        } else {
            restaurant.image = restaurantToEdit?.image ?? ""
            let errStr = dbProxy.addRecord(key: restaurant.id, record: RestaurantInDB(r: restaurant)) { _, restaurant in self.closeMe(restaurant) }   // update only
            if let s = errStr { Log.log(s) }
        }
    }

    func closeMe(_ restaurant:RestaurantInDB?) {
        guard restaurant != nil else {
            showInfoDialogBox(title: "Error", message: "Restaurant update failed")
            return
        }
        navigationController?.popViewController(animated: true)
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }
}

extension NewRestaurantController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension NewRestaurantController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0: showImagePicker(nc: self)
        case 3:
            let vc = pushViewController(storyBoard: "Restaurants", id: "MenuList") as! MenuListViewController
            vc.restaurant = restaurantToEdit!
            vc.completionCallback = { [weak self] menuList in
                self?.restaurantToEdit?.menus = menuList
                self?.fillMenus()
            }
        default: break
        }
    }
}

extension NewRestaurantController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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
