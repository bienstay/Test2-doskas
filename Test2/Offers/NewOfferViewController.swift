//
//  NewOfferViewController.swift
//  Test2
//
//  Created by maciulek on 24/02/2022.
//

import UIKit
import Kingfisher

class NewOfferViewController: UITableViewController {

    var offerToEdit: Offer?
    var photoUpdated: Bool = false

    @IBOutlet var photoImageView: UIImageView! {
        didSet {
            photoImageView.layer.cornerRadius = 10.0
            photoImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet var titleTextField: RoundedTextField! {
        didSet {
            titleTextField.tag = 1
            titleTextField.becomeFirstResponder()
            titleTextField.delegate = self
        }
    }
    @IBOutlet var subtitleTextField: RoundedTextField! {
        didSet {
            subtitleTextField.tag = 2
            subtitleTextField.delegate = self
        }
    }
    @IBOutlet var textTextView: UITextView! {
        didSet {
            textTextView.tag = 3
            textTextView.layer.cornerRadius = 10.0
            textTextView.layer.masksToBounds = true
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        if let offer = offerToEdit {  // if postToEdit is not null then we are editing the existing post
            titleTextField.text = offer.title
            subtitleTextField.text = offer.subTitle
            textTextView.text = offer.text
            if let url = URL(string: offer.imageURL) {
                photoImageView.kf.setImage(with: url)
            }
            title = offer.title
        } else {
            title = "New Offer"
        }
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        var message: String?
        if titleTextField.text == "" { message = NSLocalizedString("Title missing") } else
        if subtitleTextField.text == "" { message = NSLocalizedString("Subtitle missing") } else
        if textTextView.text == "" { message = NSLocalizedString("Text missing") } else
        if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }
        if let message = message {
            showInfoDialogBox(title: "Oops", message: message)
            return
        }

        var offer = Offer()
        offer.title = titleTextField.text!
        offer.subTitle = subtitleTextField.text!
        offer.text = textTextView.text!
        if let orgOffer = offerToEdit {
            offer.id = orgOffer.id
        }
        else {
            offer.id = nil
        }
        if photoUpdated {
            storageProxy.uploadImage(forLocation: .NEWS, image: photoImageView.image!, imageName: offer.id) { error, photoURL in
                if let photoURL = photoURL {
                    offer.imageURL = photoURL
                    let errStr = dbProxy.addRecord(key: offer.id, record: offer) { offer in self.closeMe(offer) }
                    if let s = errStr { Log.log(s) }
                }
            }
        } else {
            offer.imageURL = offerToEdit?.imageURL ?? ""
            let errStr = dbProxy.addRecord(key: offer.id, record: offer) { offer in self.closeMe(offer) }   // update only
            if let s = errStr { Log.log(s) }
        }

    }

    func closeMe(_ offer:Offer?) {
        guard offer != nil else {
            showInfoDialogBox(title: "Error", message: "Offer update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
        }
    }
}

extension NewOfferViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}

extension NewOfferViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImagePicker(nc: self)
        }
    }
}

extension NewOfferViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

