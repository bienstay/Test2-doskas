//
//  NewActivityViewController.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import UIKit

class NewActivityViewController: UITableViewController {

    var activityToEdit: Activity?
    var dowIndex: Int?   // must be set before creating this controller!
    private var photoUpdated: Bool = false
    let spinner = SpinnerViewController()

    @IBOutlet private weak var dowLabel: UILabel!
    @IBOutlet private weak var titleText: RoundedTextField!
    @IBOutlet private weak var subtitleText: RoundedTextField!
    @IBOutlet private weak var activityText: UITextView!
    @IBOutlet private weak var startDatePickerView: UIDatePicker!
    @IBOutlet private weak var endDatePickerView: UIDatePicker!
    @IBOutlet private weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.delegate = self
        subtitleText.delegate = self

        titleText.tag = 1
        subtitleText.tag = 2
        activityText.tag = 3
        titleText.becomeFirstResponder()

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        if let dowIndex = dowIndex {
            dowLabel.text = Activity.DOW.allCases[dowIndex].rawValue
        }
        // if the activity index is not null then we are editing the existing activity
        if let activity = activityToEdit {
            titleText.text = activity.title
            subtitleText.text = activity.subtitle
            activityText.text = activity.text
            startDatePickerView.date = activity.start
            endDatePickerView.date = activity.end
            if let url = URL(string: activity.imageFileURL) {
                imageView.kf.setImage(with: url)
            }
            title = activity.title
        } else {
            title = "New Activity"
        }

//        startDatePickerView.addTarget(self, action: #selector(datePickerAction), for: .allEditingEvents)
//        endDatePickerView.addTarget(self, action: #selector(datePickerAction), for: .allEditingEvents)
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
        guard let title = titleText.text, !title.isEmpty else {
            showInfoDialogBox(title: "Oops", message: "Title missing")
            return
        }
        guard let subtitle = subtitleText.text, !subtitle.isEmpty else {
            showInfoDialogBox(title: "Oops", message: "Subtitle missing")
            return
        }
        guard let dowIndex = dowIndex else {
            showInfoDialogBox(title: "Oops", message: "Day of the week not set")
            return
        }
        
        let dow = Activity.DOW.allCases[dowIndex]

        var activity = Activity()
        activity.title = titleText.text!
        activity.subtitle = subtitleText.text!
        activity.text = activityText.text!
        activity.start = startDatePickerView.date
        activity.end = endDatePickerView.date
        activity.imageFileURL = ""
        if let orgActivity = activityToEdit {
            activity.timestamp = orgActivity.timestamp
            activity.id = orgActivity.id
        }
        else {
            activity.timestamp = Date()
            activity.id = nil
        }
        if photoUpdated {
            spinner.start(vc: self)
            storageProxy.uploadImage(forLocation: .ACTIVITIES, image: imageView.image!, imageName: activity.title) { [weak self] error, photoURL in
                self?.spinner.stop(vc: self!)
                if let photoURL = photoURL {
                    activity.imageFileURL = photoURL
                    self?.updateDB(activity: activity, dow: dow.rawValue)
                }
            }
        } else {
            if let orgActivity = activityToEdit {
                activity.imageFileURL = orgActivity.imageFileURL
            }
            updateDB(activity: activity, dow: dow.rawValue)
        }

    }

    func updateDB(activity: Activity, dow: String) {
        let errStr = dbProxy.addRecord(key: activity.id, subNode: dow, record: activity) { _, activity in self.closeMe(activity) }
        if let s = errStr { Log.log(s) }
    }

    func closeMe(_ a: Activity?) {
        guard a != nil else {
            showInfoDialogBox(title: "Error", message: "Daily activities update failed")
            return
        }
        let parent = navigationController?.topViewController as? ActivitiesViewController
        DispatchQueue.main.async { parent?.resetDay(forward: true) }
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showImagePicker(nc: self)
        }
    }

//    @IBAction func datePickerAction(sender: UIDatePicker) {
//    }
}


extension NewActivityViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
//            imageView.contentMode = .scaleAspectFill
//            imageView.clipsToBounds = true
            photoUpdated = true
        }
        dismiss(animated: true, completion: nil)
    }
}

extension NewActivityViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
