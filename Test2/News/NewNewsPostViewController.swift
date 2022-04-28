//
//  NewNewsPostViewController.swift
//  Test2
//
//  Created by maciulek on 10/06/2021.
//

import UIKit
import Kingfisher

class NewNewsPostViewController: UITableViewController {

    var postToEdit: NewsPost?
    var photoUpdated: Bool = false
    let spinner = SpinnerViewController()


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

        if let post = postToEdit {  // if postToEdit is not null then we are editing the existing post
            titleTextField.text = post.title
            subtitleTextField.text = post.subtitle
            textTextView.text = post.text
            if let url = URL(string: post.imageFileURL) {
                photoImageView.kf.setImage(with: url)
            }
            title = post.timestamp.formatShort()
        } else {
            title = "New Post"
        }
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showInfoDialogBox(vc: self, title: "Oops", message: NSLocalizedString("Title missing"))
            return
        }
        guard let subTitle = subtitleTextField.text, !subTitle.isEmpty else {
            showInfoDialogBox(vc: self, title: "Oops", message: NSLocalizedString("Subtitle missing"))
            return
        }
        guard let text = textTextView.text, !text.isEmpty else {
            showInfoDialogBox(vc: self, title: "Oops", message: NSLocalizedString("Text missing"))
            return
        }
        guard let image = photoImageView.image else {
            showInfoDialogBox(vc: self, title: "Oops", message: NSLocalizedString("Image missing"))
            return
        }

        var post = NewsPost()
        post.title = title
        post.subtitle = subTitle
        post.text = text
        if let orgPost = postToEdit {
            post.timestamp = orgPost.timestamp
            post.postId = orgPost.postId
        }
        else {
            post.timestamp = Date()
            post.postId = post.timestamp.formatForDB()
        }
        if photoUpdated {
            spinner.start(vc: self)
            storageProxy.uploadImage(forLocation: .NEWS, image: image, imageName: post.postId) { error, photoURL in
                self.spinner.stop(vc: self)
                if let photoURL = photoURL {
                    post.imageFileURL = photoURL
                    let errStr = dbProxy.addRecord(key: post.postId, record: post) { post in self.closeMe(post) }
                    if let s = errStr { Log.log(level: .ERROR, "Error updting news \(s)") }
                } else {
                    Log.log(level: .ERROR, "Error uploading image - \(String(describing: error))")
                    showInfoDialogBox(vc: self, title: "Error", message: "Error uploading image")
                }
            }
        } else {
            post.imageFileURL = postToEdit?.imageFileURL ?? ""
            let errStr = dbProxy.addRecord(key: post.postId, record: post) { post in self.closeMe(post) }   // update only
            if let s = errStr { Log.log("Error updting news \(s)") }
        }
    }

    func closeMe(_ post:NewsPost?) {
        guard post != nil else {
            showInfoDialogBox(vc: self, title: "Error", message: "Post update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
        }
    }
}

extension NewNewsPostViewController: UITextFieldDelegate {
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

extension NewNewsPostViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImagePicker(nc: self)
        }
    }
}

extension NewNewsPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

