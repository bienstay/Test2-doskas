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
    
    var userName = ""
    let roles = ["hoteladmin", "editor", "operator", "none"]

    override func viewDidLoad() {
        super.viewDidLoad()

        rolePicker.dataSource = self
        rolePicker.delegate = self
        username.text = userName
    }

    @IBAction func confirmButtonPressed(_ sender: Any) {
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
        return NSAttributedString(string: roles[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
}
