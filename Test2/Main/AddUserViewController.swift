//
//  AddUserViewController.swift
//  Test2
//
//  Created by maciulek on 13/05/2022.
//

import UIKit

class AddUserViewController: UIViewController {
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var addUserButton: UIButton!

    let roles = ["hoteladmin", "editor", "operator", "none"]

    override func viewDidLoad() {
        super.viewDidLoad()
        username.delegate = self
        username.tag = 0
        username.becomeFirstResponder()
        password.delegate = self
        password.tag = 1
        rolePicker.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(largeTitle: false, title: "Add User")
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
      }

    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets =  UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
    }

    @IBAction func addUserPressed(_ sender: Any) {
        guard let user = username.text, !user.isEmpty else {
            showInfoDialogBox(title: "Missing username", message: "Enter valid user name")
            return
            }
        guard let pass = password.text, !pass.isEmpty else {
            showInfoDialogBox(title: "Missing username", message: "Enter valid user name")
            return
        }
        let role = roles[rolePicker.selectedRow(inComponent: 0)]
        showConfirmDialogBox(title: "Confirm adding user", message: "Username: \(user)\nRole:\(role)") {
            authProxy.addUser(username: user, password: pass, role: role) { [weak self] (authData, error) in
                guard let self = self else { return }
                if let a = authData {
                    let name = a.userName.split(separator: "@")[0]
                    let role = a.role
                    let uid = a.userId
                    dbProxy.setUserRole(uid: uid, role: role) { [weak self] in
                        guard let self = self else { return }
                        self.showInfoDialogBox(title: "User added", message: "User: \(name)\nRole: \(role)\nId:\(uid)") { [weak self] _ in
                            if self?.navigationController != nil {
                                _ = self?.navigationController?.popViewController(animated: true)
                            } else {
                                self?.dismiss(animated: true)
                            }
                        }
                    }
                } else {
                    self.showInfoDialogBox(title: "Error", message: "Error adding user: \(error.debugDescription)")
                }
            }
        }
    }
}

extension AddUserViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        roles.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: roles[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
}

extension AddUserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
