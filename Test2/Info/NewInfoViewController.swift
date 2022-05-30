//
//  NewInfoViewController.swift
//  Test2
//
//  Created by maciulek on 24/05/2022.
//

import UIKit
import Kingfisher

class NewInfoViewController: UITableViewController {
    var infoToEdit: InfoItem?
    let spinner = SpinnerViewController()

    struct ImageData {
        var url: String
        var text: String
        var image: UIImage?
        var updated: Bool
    }
    var imageData: [ImageData] = []     // our outlet to collectionView cells' data
    var selectedImageIndex: Int = 0     // currently updated photo (imagePicker closure does not allow passing user parameters

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
            title = info.title
            titleTextField.text = info.title
            subtitleTextField.text = info.subtitle
            textTextView.text = info.text
            for i in info.images {
                imageData.append(ImageData(url: i.url, text: i.text, image: nil, updated: false))
            }
            loadAllImages()
        } else {
            title = "New Info"
        }
        imageData.append(ImageData(url: "", text: "", image: nil, updated: false))    // append empty one

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    func loadAllImages() {
        let group = DispatchGroup()
        for i in 0...imageData.count - 1 {
            if let url = URL(string: imageData[i].url) {
                group.enter()
                DispatchQueue.global().async { [weak self] in
                    if let data = try? Data(contentsOf: url) {
                        DispatchQueue.main.async { [weak self] in
                            self?.imageData[i].image = UIImage(data: data) ?? nil
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

    @IBAction func deletePressed(_ sender: UIButton) {
        imageData.remove(at: sender.tag)
        collectionView.reloadData()
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
        guard imageData.count > 0 else {
            showInfoDialogBox(title: "Oops", message: NSLocalizedString("Image(s) missing"))
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
        saveAllImages(info.id ?? "") { [weak self] in
            guard let self = self else { return }
            for i in self.imageData {
                if !i.url.isEmpty { info.images.append(InfoItem.ImageData(url: i.url, text: i.text)) }
            }
            let errStr = dbProxy.addRecord(key: info.id, record: info) { [weak self] _, info in self?.closeMe(info) }
            if let s = errStr { Log.log("Error updting news \(s)") }
        }
    }

    func saveAllImages(_ id:String, completionCallback: @escaping () -> ()) {
        let group = DispatchGroup()
        self.spinner.start(vc: self)
        for i in 0...imageData.count-1 {
            if let image = imageData[i].image, imageData[i].updated {
                group.enter()
                let milliseconds = Int64((Date().timeIntervalSince1970 * 1000.0).rounded()) % 1000
                let imageName = Date().formatForDBFull() + "_" + String(milliseconds)
                storageProxy.uploadImage(forLocation: .NEWS, image: image, imageName: imageName) { [weak self] error, photoURL in
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
        navigationController?.popViewController(animated: true)
//        if let nc = navigationController {
//            nc.popViewController(animated: true)
//        }
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
            if imageData[selectedImageIndex].image == nil { imageData.append(ImageData(url: "", text: "", image: nil, updated: false)) }    // we were uploading to an empty image placeholder, so create a new one

            imageData[selectedImageIndex].image = selectedImage
            imageData[selectedImageIndex].updated = true

            collectionView.reloadItems(at: [IndexPath(row: selectedImageIndex, section: 0)])
        }
        dismiss(animated: true)
    }
}

extension NewInfoViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewInfoImageCell", for: indexPath) as! NewInfoImageCollectionViewCell
        cell.titleTextField.delegate = self
        cell.draw(title: imageData[indexPath.row].text, image: imageData[indexPath.row].image)
        cell.titleTextField.tag = 100 + indexPath.row
        cell.deleteButton.tag = indexPath.row
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


/*
extension NewInfoViewController: UICollectionViewDelegateFlowLayout {
    var cellSize: Double {
        var size: Double = 280.0
//        if traitCollection.horizontalSizeClass == .compact {
//            size = UIScreen.main.bounds.width * 2.0 / 3.0
//        }
        return size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: cellSize, height: cellSize)
    }
}
*/

