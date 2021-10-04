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
        var message: String?
        if titleTextField.text == "" { message = NSLocalizedString("Title missing") } else
        if subtitleTextField.text == "" { message = NSLocalizedString("Subtitle missing") } else
        if textTextView.text == "" { message = NSLocalizedString("Text missing") } else
        if photoImageView.image == nil { message = NSLocalizedString("Image missing", comment: "Image missing") }
        if let message = message {
            showInfoDialogBox(vc: self, title: "Oops", message: message)
            return
        }

        var post = NewsPost()
        post.title = titleTextField.text!
        post.subtitle = subtitleTextField.text!
        post.text = textTextView.text!
        if let orgPost = postToEdit {
            post.timestamp = orgPost.timestamp
            post.postId = orgPost.postId
        }
        else {
            post.timestamp = Date()
            post.postId = post.timestamp.formatForSort()
        }
        if photoUpdated {
            FireB.shared.uploadImage(image: photoImageView.image!, forLocation: .NEWS, imageName: post.postId) { photoURL in
                post.imageFileURL = photoURL
                let errStr = FireB.shared.addRecord(key: post.postId, record: post) { post in self.closeMe(post) }
                if let s = errStr { Log.log(s) }
            }
        } else {
            post.imageFileURL = postToEdit!.imageFileURL
            let errStr = FireB.shared.addRecord(key: post.postId, record: post) { post in self.closeMe(post) }   // update only
            if let s = errStr { Log.log(s) }
        }

    }

    func closeMe(_ post:NewsPost?) {
        guard let post = post else {
            showInfoDialogBox(vc: self, title: "Error", message: "Post update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
            if postToEdit != nil {
                let parent = nc.topViewController as! NewsDetailViewController
                parent.post = post
                parent.tableView.reloadData()   // TODO hack
            }
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

