//
//  NewHotelViewController.swift
//  Test2
//
//  Created by maciulek on 15/11/2021.
//

import UIKit

class NewHotelConfigViewController: UITableViewController {

    private var photoUpdated: Bool = false
    var configToEdit: HotelConfig = hotel.config

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

        nameTextField.text = configToEdit.name
        if let fileName = configToEdit.image, let url = URL(string: fileName) {
            photoImageView.kf.setImage(with: url)
        }
        title = configToEdit.name
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
            showInfoDialogBox(title: "Oops", message: message)
            return
        }

        var hc = HotelConfig()
        hc.name = nameTextField.text!
        hc.socialURLs = configToEdit.socialURLs // TODO
        hc.rooms = configToEdit.rooms   // TODO

        if photoUpdated {
            storageProxy.uploadImage(forLocation: .BASE, image: photoImageView.image!, imageName: hc.name) { error, photoURL in
                if let photoURL = photoURL {
                    hc.image = photoURL
                    self.addHotelConfigToDB(config: hc)
                }
            }
        } else {
            hc.image = configToEdit.image ?? ""
            addHotelConfigToDB(config: hc)
        }
    }

    func addHotelConfigToDB(config hc: HotelConfig) {
        let configInDB = HotelConfigInDB(h: hc)
        let errStr = dbProxy.addRecord(key: "config", record: configInDB) { _, hc in self.closeMe(hc) }
        if let s = errStr { Log.log(s) }
    }

    func closeMe(_ hc: HotelConfigInDB?) {
        guard hc != nil else {
            showInfoDialogBox(title: "Error", message: "Hotel update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)

            phoneUser.startObserving()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImagePicker(nc: self)
        }
    }
}


extension NewHotelConfigViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            photoImageView.image = selectedImage
            photoUpdated = true
        }
        dismiss(animated: true, completion: nil)
    }
}

extension NewHotelConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
