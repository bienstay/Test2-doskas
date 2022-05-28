//
//  NewActivityViewController.swift
//  Test2
//
//  Created by maciulek on 04/10/2021.
//

import UIKit

class NewActivityViewController: UITableViewController {

    var activityIndexToEdit: Int?
    var dowIndex: Int = 0   // must be set before creating this controller!
    private var photoUpdated: Bool = false

    @IBOutlet private weak var dowLabel: UILabel!
    @IBOutlet private weak var startDatePickerView: UIDatePicker!
    @IBOutlet private weak var endDatePickerView: UIDatePicker!
    @IBOutlet private weak var activityImageView: UIImageView!
    @IBOutlet private weak var subtitleLabel: RoundedTextField!
    @IBOutlet private weak var activityText: UITextView!
    @IBOutlet private weak var titleLabel: RoundedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.delegate = self
        subtitleLabel.delegate = self

        titleLabel.tag = 1
        subtitleLabel.tag = 2
        activityText.tag = 3
        titleLabel.becomeFirstResponder()

        // Dismiss keyboard when users tap any blank area of the view
        let tap = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        dowLabel.text = Activity.DOW.allCases[dowIndex].rawValue
        // if the activity index is not null then we are editing the existing activity
        if let activityIndex = activityIndexToEdit {
            if let activity = hotel.activities[dowIndex]?[activityIndex] {
                titleLabel.text = activity.title
                subtitleLabel.text = activity.subtitle
                startDatePickerView.date = activity.start
                endDatePickerView.date = activity.end
                activityText.text = activity.text
                if let url = URL(string: activity.imageFileURL) {
                    activityImageView.kf.setImage(with: url)
                }
                title = activity.title
            }
        } else {
            title = "New Activity"
        }
        
        startDatePickerView.addTarget(self, action: #selector(datePickerAction), for: .allEditingEvents)
        endDatePickerView.addTarget(self, action: #selector(datePickerAction), for: .allEditingEvents)
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
        guard !(titleLabel.text?.isEmpty ?? false) else {
            showInfoDialogBox(title: "Oops", message: "Title missing")
            return
        }
        guard !(subtitleLabel.text?.isEmpty ?? false) else {
            showInfoDialogBox(title: "Oops", message: "Location missing")
            return
        }

        let dow = Activity.DOW.allCases[dowIndex]

        var activity = Activity()
        if let i = activityIndexToEdit { activity.id = hotel.activities[dowIndex]?[i].id }
        activity.title = titleLabel.text!
        activity.subtitle = subtitleLabel.text!
        activity.text = activityText.text!
        activity.start = startDatePickerView.date
        activity.end = endDatePickerView.date
        activity.imageFileURL = ""

        if photoUpdated {
            storageProxy.uploadImage(forLocation: .ACTIVITIES, image: activityImageView.image!, imageName: activity.title) { error, photoURL in
                if let photoURL = photoURL {
                    activity.imageFileURL = photoURL
                    self.updateArrayAndDB(activity: activity, dow: dow.rawValue)
                }
            }
        } else {
            if let i = activityIndexToEdit {
                activity.imageFileURL = hotel.activities[dowIndex]![i].imageFileURL
            }
            self.updateArrayAndDB(activity: activity, dow: dow.rawValue)
        }

    }

    func updateArrayAndDB(activity: Activity, dow: String) {
        let errStr = dbProxy.addRecord(key: activity.id, subNode: dow, record: activity) { activity in self.closeMe(activity) }
        if let s = errStr { Log.log(s) }
    }

    func closeMe(_ a: Activity?) {
        guard a != nil else {
            showInfoDialogBox(title: "Error", message: "Daily activities update failed")
            return
        }
        if let nc = navigationController {
            nc.popViewController(animated: true)
            let parent = nc.topViewController as! ActivitiesViewController
            DispatchQueue.main.async { parent.resetDay(forward: true) }
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showPicturePicker(vc: self)
        }
    }

    @IBAction func datePickerAction(sender: UIDatePicker) {
    }
}


extension NewActivityViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            activityImageView.image = selectedImage
            activityImageView.contentMode = .scaleAspectFill
            activityImageView.clipsToBounds = true
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
