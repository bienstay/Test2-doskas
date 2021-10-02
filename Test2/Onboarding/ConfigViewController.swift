//
//  ConfigViewController.swift
//  Test2
//
//  Created by maciulek on 12/09/2021.
//

import UIKit

class ConfigViewController: UIViewController {
    @IBOutlet var dialogView: UIView!
    @IBOutlet var hotelPicker: UIPickerView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var roomNumberTextField: UITextField!
    @IBOutlet var adminSwitch: UISwitch!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet var saveButton: UIButton!
    var exitHandler: (() -> Void)?

//    var pickerData: [(String, [String])] = [
//        ("SheratonFullMoon", []),
//        ("W", [])
//    ]

    private struct H {
        var id: String
        var name: String
    }
    
    private var pickerData: [(H, [(String, GuestInfo)])] = [
        (H(id: "SheratonFullMoon", name: "Sheraton"), []),
        (H(id: "W", name: "W"), [])
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hotelPicker.delegate = self
        self.hotelPicker.dataSource = self
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        dialogView.layer.cornerRadius = 16.0
        dialogView.layer.borderWidth = 1
        dialogView.layer.borderColor = UIColor.black.cgColor

        for i in 0...pickerData.count - 1 {
            FireB.shared.getGuests(hotelID: pickerData[i].0.id) { dbGuests in
                dbGuests.forEach({self.pickerData[i].1.append(($0.0, $0.1))})
                self.pickerData[i].1.sort(by: { $0.1.roomNumber < $1.1.roomNumber } )
                DispatchQueue.main.async { self.hotelPicker.reloadAllComponents() }
            }
        }
    }

    static func showPopup(parentVC: UIViewController, completionHandler: (() -> Void)? = nil ) {
        if let popupViewController = UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "ConfigViewController") as? ConfigViewController {
            popupViewController.modalPresentationStyle = .overCurrentContext
            popupViewController.modalTransitionStyle = .crossDissolve
            popupViewController.exitHandler = completionHandler
            parentVC.present(popupViewController, animated: true)
        }
    }

    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func savePressed(_ sender: Any) {
        let hotelIdx = hotelPicker.selectedRow(inComponent: 0)
        let guestIdx = hotelPicker.selectedRow(inComponent: 1)
        hotel.id = pickerData[hotelIdx].0.id
        guest.id = pickerData[hotelIdx].1[guestIdx].0

        FireB.shared.removeAllObservers()
        guest.startObserving()
        hotel.startObserving()

        exitHandler?()
        self.dismiss(animated: true, completion: nil)
    }
}

extension ConfigViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return pickerData.count }
        let selectedHotel = hotelPicker.selectedRow(inComponent: 0)
        return pickerData[selectedHotel].1.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return pickerData[row].0.name }
        else {
            let selectedHotel = hotelPicker.selectedRow(inComponent: 0)
            let guest = pickerData[selectedHotel].1[row].1
            return String(guest.roomNumber) + " " + guest.Name
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadAllComponents()
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let label = (view as? UILabel) ?? UILabel()

        var s: String
        if component == 0 { s = pickerData[row].0.name }
        else {
            let selectedHotel = hotelPicker.selectedRow(inComponent: 0)
            let guest = pickerData[selectedHotel].1[row].1
            s = String(guest.roomNumber) + " " + guest.Name
        }

        label.text = s
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)

        return label
    }
}
