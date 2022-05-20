//
//  EditUserViewController.swift
//  Test2
//
//  Created by maciulek on 15/05/2022.
//

import UIKit

class EditUserViewController: UIViewController {

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var rolePicker: UIPickerView!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    var user: AuthenticationData!
    let roles = Role.allCases

    override func viewDidLoad() {
        super.viewDidLoad()

        rolePicker.dataSource = self
        rolePicker.delegate = self
        username.text = user.name
        rolePicker.selectRow(roles.firstIndex(where: { $0 == user.role }) ?? 0, inComponent: 0, animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presentingViewController?.viewWillDisappear(true)
    }

    // this is to make the parent call viewWillAppear even if this modal did not cover 100% of the screen
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presentingViewController?.viewWillAppear(true)
    }

    @IBAction func resetPasswordButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let uid = user.uid
        let newPassword = authProxy.defaultPassword
        authProxy.updateUser(uid: uid, newPassword: newPassword) { [weak self] (error) in
            sender.isEnabled = true
            if let error = error {
                self?.showInfoDialogBox(title: "Error", message: "Error updating the user with id \(uid)\n\(error)") { _ in
                    self?.dismiss(animated: true)
                }
            } else {
                self?.showInfoDialogBox(title: "Success", message: "User password updated") { _ in
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    @IBAction func confirmButtonPressed(_ sender: UIButton) {
        sender.isEnabled = false
        let role = roles[rolePicker.selectedRow(inComponent: 0)]
        authProxy.setUserRole(uid: user.uid, role: role) { [weak self] error in
            sender.isEnabled = true
            guard let self = self else { return }
            if let error = error {
                self.showInfoDialogBox(title: "Error saving user", message: "\(error)") { _ in
                    self.dismiss(animated: true)
                }
            } else {
                self.showInfoDialogBox(title: "\(self.user.name) updated", message: "New role: \(role.rawValue)") { _ in
                    self.dismiss(animated: true)
                }
            }
        }
    }
}

extension EditUserViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return roles.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: roles[row].rawValue, attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
}
