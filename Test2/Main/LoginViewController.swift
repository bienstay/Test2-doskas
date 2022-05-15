//
//  LoginViewController.swift
//  Test2
//
//  Created by maciulek on 09/05/2022.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var hotelPicker: UIPickerView!
    @IBOutlet weak var scrollView: UIScrollView!

    var hotels: [String] = ["RitzKohSamui", "SheratonFullMoon", "W"]

    override func viewDidLoad() {
        super.viewDidLoad()
        hotelPicker.dataSource = self
        hotelPicker.delegate = self
        username.delegate = self
        username.tag = 0
        username.becomeFirstResponder()
        password.delegate = self
        password.tag = 1
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @IBAction func login(_ sender: Any) {
        guard let user = username.text, !user.isEmpty else {
            showInfoDialogBox(title: "Missing username", message: "Enter valid user name")
            return
            }
        guard let pass = password.text, !pass.isEmpty else {
            showInfoDialogBox(title: "Missing username", message: "Enter valid user name")
            return
        }
        let hotelId = "RitzKohSamui"
        let barcodeString = """
        { "hotelId": "\(hotelId)", "userName": "\(user)", "password": "\(pass)" }
        """
        UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initFromBarcode()
        appDelegate.transitionToHome(from: self)
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
}


extension LoginViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return hotels.count
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: hotels[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.red])
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextTextField = view.viewWithTag(textField.tag + 1) {
            textField.resignFirstResponder()
            nextTextField.becomeFirstResponder()
        }
        return true
    }
}
