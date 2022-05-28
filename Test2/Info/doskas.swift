//
//  doskas.swift
//  Test2
//
//  Created by maciulek on 26/05/2022.
//

import Foundation
//
//  NewInfoViewController.swift
//  Test2
//
//  Created by maciulek on 24/05/2022.
//
/*
import UIKit
import Kingfisher

class NewInfoViewController: UITableViewController {
    var infoToEdit: InfoItem?
    let spinner = SpinnerViewController()

    //var updatedImages: [Int:UIImage] = [:]      // outlet for updated images (binary)
    var images: [UIImage] = []      // outlet for updated images (binary)
    var imageData: [InfoItem.ImageData] = []    // outlet for the url and text of images

    var selectedImageIndex: Int = 0             // currently updated photo (closure does not allow passing user parameters

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
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        if let info = infoToEdit {  // if postToEdit is not null then we are editing the existing post
            titleTextField.text = info.title
            subtitleTextField.text = info.subtitle
            textTextView.text = info.text
            title = info.title
        } else {
            title = "New Info"
        }
        
        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func loadAllImages(from info: InfoItem) {
        let group = DispatchGroup()
        imageData = info.images
        for i in 0...imageData.count - 1 {
            if let url = URL(string: imageData[i].url) {
                group.enter()
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async {
                            self.images[i] = UIImage(data: data) ?? UIImage()
                            group.leave()
                        }
                    } else {
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true)
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        guard let title = titleTextField.text, !title.isEmpty else {
            showInfoDialogBox(title: "Oops", message: NSLocalizedString("Title missing"))
            return
        }
        guard let subTitle = subtitleTextField.text, !subTitle.isEmpty else {
            showInfoDialogBox(title: "Oops", message: NSLocalizedString("Subtitle missing"))
            return
        }
        guard let text = textTextView.text, !text.isEmpty else {
            showInfoDialogBox(title: "Oops", message: NSLocalizedString("Text missing"))
            return
        }

        var info = InfoItem()
        info.title = title
        info.subtitle = subTitle
        info.text = text
        if let orgInfo = infoToEdit {
            info.timestamp = orgInfo.timestamp
            info.id = orgInfo.id
        }
        else {
            info.timestamp = Date()
            info.id = info.timestamp.formatForDB()
        }
        saveAllImages() { [weak self] in
            info.images = self?.imageData ?? []
            let errStr = dbProxy.addRecord(key: info.id, record: info) { [weak self] info in self?.closeMe(info) }
            if let s = errStr { Log.log("Error updting news \(s)") }
        }
    }

    func saveAllImages(completionCallback: @escaping () -> ()) {
        let group = DispatchGroup()
        self.spinner.start(vc: self)
        //for i in updatedImages {
        for i in 0...images.count {
            if  let id = infoToEdit?.id {
                let imageName = id + "-" + String(i)
                group.enter()
                storageProxy.uploadImage(forLocation: .NEWS, image: images[i], imageName: imageName) { [weak self] error, photoURL in
                    if let photoURL = photoURL, let self = self {
                        self.imageData[i].url = photoURL
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: DispatchQueue.global()) {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.spinner.stop(vc: self)
                completionCallback()
            }
        }
    }

    func closeMe(_ info:InfoItem?) {
        guard info != nil else {
            showInfoDialogBox(title: "Error", message: "Info update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImagePicker(nc: self)
        }
    }
}

extension NewInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo mediaInfo: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = mediaInfo[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("selectedimageIndex = \(selectedImageIndex)")
            let cell = collectionView.cellForItem(at: IndexPath(row: selectedImageIndex, section: 0)) as! NewInfoImageCollectionViewCell
            cell.picture.image = selectedImage
            updatedImages[selectedImageIndex] = selectedImage
            //collectionView.reloadItems(at: <#T##[IndexPath]#>)
        }
        dismiss(animated: true)
    }
}

extension NewInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return (infoToEdit?.images.count ?? 0) + 1  // add a placeholder for an empty image
        return imageData.count + 1  // add a placeholder for an empty image
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewInfoImageCell", for: indexPath) as! NewInfoImageCollectionViewCell
        cell.titleTextField.delegate = self
        if indexPath.row < imageData.count {
            cell.draw(title: imageData[indexPath.row].text, image: imageData[indexPath.row].url)
            cell.titleTextField.tag = 100 + indexPath.row
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedImageIndex = indexPath.row
        showImagePicker(nc: self)
    }
}

extension NewInfoViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }

    // this is called when textfield loses focus but it is too late if a button is pressed, so we need the below as well
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag >= 100 {
            imageData[textField.tag - 100].text = textField.text ?? ""
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag >= 100, let text = textField.text, let textRange = Range(range, in: text) {
            let updatedText = text.replacingCharacters(in: textRange, with: string)
            imageData[textField.tag - 100].text = updatedText
        }
        return true
    }
}

*/

