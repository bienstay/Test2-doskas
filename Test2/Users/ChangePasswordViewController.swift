//
//  ChangePasswordViewController.swift
//  Test2
//
//  Created by maciulek on 15/05/2022.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var newPassword: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        username.text = phoneUser.id
        oldPassword.delegate = self
        oldPassword.tag = 0
        oldPassword.becomeFirstResponder()
        newPassword.delegate = self
        newPassword.tag = 1
        /*
        changeButton.backgroundColor = .clear
        changeButton.layer.cornerRadius = 30
        changeButton.layer.borderWidth = 1
        changeButton.layer.borderColor = UIColor.red.cgColor
        */
        if UIDevice.current.userInterfaceIdiom != .pad {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        //let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        //scrollView.contentInset = contentInsets
        //scrollView.scrollIndicatorInsets = contentInsets
        let frame = changeButton.convert(changeButton.bounds, to: scrollView)  // get absolute coordinates of the button
        let offset = keyboardSize.height - (view.frame.height - frame.maxY) + 8 // add 8 points of space
        if self.view.frame.origin.y == 0 && offset > 0 {
            self.view.frame.origin.y -= offset
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        //let contentInsets =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        //scrollView.contentInset = contentInsets
        //scrollView.scrollIndicatorInsets = contentInsets
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }


    @IBAction func changeButtonPressed(_ sender: UIButton) {
        guard let oldpass = oldPassword.text else {
            showInfoDialogBox(title: "Missing field", message: "Current password missing")
            return
        }
        guard let newpass = newPassword.text else {
            showInfoDialogBox(title: "Missing field", message: "New password missing")
            return
        }
        sender.isEnabled = false
        dbProxy.changePassword(oldPassword: oldpass, newPassword: newpass) { [weak self] error in
            sender.isEnabled = true
            if let error = error {
                self?.showInfoDialogBox(title: "Error changing password", message: "\(error)")
                return
            }
            self?.showInfoDialogBox(title: "Success", message: "Password changed") { [weak self] _ in
                if self?.navigationController != nil {
                    _ = self?.navigationController?.popViewController(animated: true)
                } else {
                    self?.dismiss(animated: true)
                }
            }
        }
    }    
}

extension ChangePasswordViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
