//
//  NewHotelViewController.swift
//  Test2
//
//  Created by maciulek on 15/11/2021.
//

import UIKit

class UpdateHotelInfoViewController: UITableViewController {

    private var photoUpdated: Bool = false
    var hotelToEdit: Hotel? = nil

    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var nameTextField: RoundedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self

        photoImageView.contentMode = .scaleAspectFill
        photoImageView.clipsToBounds = true

        nameTextField.tag = 1
        nameTextField.becomeFirstResponder()

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        if let hotel = hotelToEdit {  // if hotelToEdit is not null then we are editing the existing hotel
            nameTextField.text = hotel.name
            if let url = URL(string: hotel.image) {
                photoImageView.kf.setImage(with: url)
            }
            title = hotel.name
        } else {
            title = "New Hotel"
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var message: String?
        if nameTextField.text == "" { message = NSLocalizedString("Name missing") } else
        if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }
        if let message = message {
            showInfoDialogBox(vc: self, title: "Oops", message: message)
            return
        }

        // TODO - instead of substituting the global, set only the ID and read the rest from DB
        // need to add sync of the hotel info
        let h = Hotel()
        h.name = nameTextField.text!
        if let orgHotel = hotelToEdit {
            h.id = orgHotel.id
        } else {
            h.id = h.name.filter { !$0.isWhitespace }
        }

        if photoUpdated {
            dbProxy.uploadImage(image: photoImageView.image!, forLocation: .BASE, imageName: h.name) { photoURL in
                h.image = photoURL
                self.addHotelInfoToDB(hotel: h)
            }
        } else {
            h.image = hotelToEdit?.image ?? ""
            addHotelInfoToDB(hotel: h)
        }
    }

    func addHotelInfoToDB(hotel h: Hotel) {
        let hotelInfo = HotelInfo(name: h.name, image: h.image, socialURLs: [:])
        let errStr = dbProxy.addRecord(key: "info", record: hotelInfo) { h in self.closeMe(h) }
        if let s = errStr { Log.log(s) }
        //dbProxy.addHotelToConfig(hotelId: h.id!, hotelName: h.name)
    }
/*
    func addHotelToDB(hotel h: Hotel) {
        let hotelInDB = HotelInDB(hotel: h)
        let errStr = dbProxy.addRecord(key: h.id, record: hotelInDB) { h in self.closeMe(h) }
        if let s = errStr { Log.log(s) }
        dbProxy.addHotelToConfig(hotelId: h.id!, hotelName: h.name)
    }
*/
    func closeMe(_ h: HotelInfo?) {
        guard h != nil else {
            showInfoDialogBox(vc: self, title: "Error", message: "Hotel update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)

            guest.startObserving()
            hotel.startObserving()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showPicturePicker(vc: self)
        }
    }
}


extension UpdateHotelInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoUpdated = true
        }
        dismiss(animated: true, completion: nil)
    }
}

extension UpdateHotelInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
