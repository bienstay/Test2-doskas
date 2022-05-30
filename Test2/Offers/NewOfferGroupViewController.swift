//
//  NewOfferGroupViewController.swift
//  Test2
//
//  Created by maciulek on 29/05/2022.
//

import UIKit

class NewOfferGroupViewController: UIViewController {
    var groupToEdit: OfferGroup?

    @IBOutlet private weak var titleText: RoundedTextField!
    @IBOutlet private weak var subtitleText: RoundedTextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        titleText.delegate = self
        subtitleText.delegate = self

        titleText.tag = 1
        subtitleText.tag = 2
        titleText.becomeFirstResponder()

        // if the group is not null then we are editing the existing activity
        if let group = groupToEdit {
            titleText.text = group.title
            subtitleText.text = group.subTitle
            title = group.title
        } else {
            title = "New Offer Group"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.tintColor = .black
    }

    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        guard let title = titleText.text, !title.isEmpty else {
            showInfoDialogBox(title: "Oops", message: "Title missing")
            return
        }

        var group = OfferGroup()
        group.title = titleText.text!
        group.subTitle = subtitleText.text!
        if let orgGroup = groupToEdit {
            group.id = orgGroup.id
            group.offers = orgGroup.offers
        }
        else {
            group.id = nil
        }

        let errStr = dbProxy.addRecord(key: group.id, subNode: nil, record: group) { _, group in self.closeMe(group) }
        if let s = errStr { Log.log(s) }
    }

    func closeMe(_ a: OfferGroup?) {
        guard a != nil else {
            showInfoDialogBox(title: "Error", message: "Offer group update failed")
            return
        }
        navigationController?.popViewController(animated: true)
    }
}

extension NewOfferGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}


