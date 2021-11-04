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

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        
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
        } else {
            title = "New Restaurant"
        }
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var message: String?
        if nameTextField.text == "" { message = NSLocalizedString("Name missing", comment: "Name missing") } else
        if cuisinesTextField.text == "" { message = NSLocalizedString("Type missing", comment: "Type missing") } else
        if locationTextField.text == "" { message = NSLocalizedString("Location missing", comment: "Location missing") } else
        if descriptionTextView.text == "" { message = NSLocalizedString("Description missing", comment: "Description missing") } else
        //if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }
        if let message = message {
            showInfoDialogBox(vc: self, title: "Oops", message: message)
            return
        }

        let restaurant = Restaurant()
        restaurant.name = nameTextField.text ?? ""
        restaurant.cuisines = cuisinesTextField.text ?? ""
        restaurant.description = descriptionTextView.text ?? ""
        restaurant.phone = phoneTextField.text ?? ""

        restaurant.location = locationTextField.text ?? ""
        restaurant.geoLatitude = Double(latitudeTextField.text!) ?? 0.0
        restaurant.geoLongitude = Double(longitudeTextField.text!) ?? 0.0
        
        if let orgRestaurant = restaurantToEdit {
            restaurant.id = orgRestaurant.id
        }
        
        if photoUpdated {
            FireB.shared.uploadImage(image: photoImageView.image!, forLocation: .RESTAURANTS, imageName: restaurant.name) { photoURL in
                    restaurant.image = photoURL
                    let errStr = FireB.shared.addRecord(key: restaurant.id, record: restaurant) { restaurant in self.closeMe(restaurant) }
                    if let s = errStr { Log.log(s) }
                }
        } else {
            restaurant.image = restaurantToEdit?.image ?? ""
            let errStr = FireB.shared.addRecord(key: restaurant.id, record: restaurant) { restaurant in self.closeMe(restaurant) }   // update only
            if let s = errStr { Log.log(s) }
        }
    }
    
    func closeMe(_ restaurant:Restaurant?) {
        guard restaurant != nil else {
            showInfoDialogBox(vc: self, title: "Error", message: "Restaurant update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
        }
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
/*
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
*/
}

extension NewRestaurantController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
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
            photoSourceRequestController.addAction(cameraAction)
            photoSourceRequestController.addAction(photoLibraryAction)
            
            // For iPad
            if let popoverController = photoSourceRequestController.popoverPresentationController {
                if let cell = tableView.cellForRow(at: indexPath) {
                    popoverController.sourceView = cell
                    popoverController.sourceRect = cell.bounds
                }
            }
            present(photoSourceRequestController, animated: true, completion: nil)
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

