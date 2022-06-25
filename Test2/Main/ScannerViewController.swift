//
//  ScannerViewController.swift
//  Test2
//
//  Created by maciulek on 26/03/2022.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet weak var captureView: UIView!
    @IBOutlet weak var skipCaptureButton: UIButton!
    @IBOutlet weak var defaultsStackView: UIStackView!
    @IBOutlet weak var userFlagControl: UISegmentedControl!
    @IBOutlet weak var hotelPicker: UIPickerView!
    @IBOutlet weak var userPicker: UIPickerView!
    @IBOutlet weak var switchButton: UIButton!

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    var hotels: [String] = []
    var users: [AuthenticationData] = []
    var rooms: [Int] = []

    var userFlag:Bool { userFlagControl.selectedSegmentIndex == 0 }
    enum Picker:Int {
        case Hotel = 0
        case User = 1
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        hotelPicker.dataSource = self
        hotelPicker.delegate = self
        hotelPicker.tag = Picker.Hotel.rawValue
        userPicker.dataSource = self
        userPicker.delegate = self
        userPicker.tag = Picker.User.rawValue

        hotelPicker.selectRow(0, inComponent: 0, animated: true)
        initUserList()
        initRoomList()

        defaultsStackView.isHidden = true
        hotelPicker.tintColor = .yellow
        userPicker.tintColor = .yellow

        //view.backgroundColor = UIColor(216, 77, 68) // rgb - taken from the color picker from log but different
        view.backgroundColor = UIColor(234, 62, 59) // sRGB -

        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
            switchButtonPressed(UIButton())
            switchButton.isEnabled = false
            return
        }

        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed()
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //previewLayer.frame = view.layer.bounds
        previewLayer.frame = captureView.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        //view.layer.addSublayer(previewLayer)
        captureView.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func initHotelList() {
        hotels = []
        dbProxy.getHotelList() { [weak self] hotelList in
            self?.hotels = hotelList.keys.sorted()
            self?.initUserList()
            self?.initRoomList()
            DispatchQueue.main.async {
                self?.hotelPicker.reloadAllComponents()
            }
        }
    }

    func initUserList() {
        guard !hotels.isEmpty else { return }
        users = []
        userPicker.reloadComponent(0)
        let i = hotelPicker.selectedRow(inComponent: 0)
        let hotelId = hotels[i].lowercased()
        authProxy.getUsers(hotelName: hotelId) { [weak self] userList in
            self?.users = userList
            DispatchQueue.main.async { self?.userPicker.reloadAllComponents() }
        }
    }
    
    func initRoomList() {
        guard !hotels.isEmpty else { return }
        users = []
        userPicker.reloadComponent(0)
        let i = hotelPicker.selectedRow(inComponent: 0)
        let hotelId = hotels[i]
        dbProxy.getRoomList(hotelId: hotelId) { [weak self] roomList in
            self?.rooms = roomList
            DispatchQueue.main.async { self?.userPicker.reloadAllComponents() }
        }
    }

    func failed() {
        DispatchQueue.main.async {
            let ac = UIAlertController(title: "Scanning not supported", message: "This device does not support scanning a code", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(ac, animated: true)
            self.captureSession = nil
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true

        if (captureSession?.isRunning == false && !captureSession.inputs.isEmpty ) {
            captureSession.startRunning()
        }
        initHotelList()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(barcodeString: stringValue)
        }
    }

    @IBAction func segmentedIndexChanged(_ sender: UISegmentedControl) {
        userPicker.selectRow(0, inComponent: 0, animated: false)
        userPicker.reloadAllComponents()
    }

    @IBAction func switchButtonPressed(_ sender: UIButton) {
        captureView.isHidden = !captureView.isHidden
        captureView.isHidden ? captureSession?.stopRunning() : captureSession?.startRunning()
        view.backgroundColor = captureView.isHidden ? .white : UIColor(234, 62, 59) // sRGB
        defaultsStackView.isHidden = !defaultsStackView.isHidden
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        _ = presentModal(storyBoard: "Users", id: "Login")
    }

    @IBAction func skipCaptureButtonPressed(_ sender: UIButton) {
        let hotelId = hotels[hotelPicker.selectedRow(inComponent: 0)]
        if userFlag && !users.isEmpty {
            let userId: String = users[userPicker.selectedRow(inComponent: 0)].name
            found(barcodeString: """
            { "hotelId": "\(hotelId)", "userName": "\(userId)", "password": "\(hotelId.lowercased())" }
        """)
        } else if !rooms.isEmpty {
            let room = rooms[userPicker.selectedRow(inComponent: 0)]
            found(barcodeString: """
            { "hotelId": "\(hotelId)", "roomNumber": \(room), "startDate": 669364704.669543, "guestName": "" }
        """)
        }
    }

    func found(barcodeString: String) {
        Log.log(level: .INFO, "Barcode scanned: \(barcodeString)")
        guard let b: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession?.startRunning() }
            return
        }
        Log.log(level: .INFO, "Barcode parsed: \(b)")

        guard b.isValid() else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }

        goToHome(barcodeString: barcodeString)
    }

    func goToHome(barcodeString: String) {
        UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initFromBarcode()
        appDelegate.transitionToHome(from: self)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

extension ScannerViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView.tag {
            case Picker.Hotel.rawValue: return hotels.count
            case Picker.User.rawValue:
                return userFlag ? users.count : rooms.count
            default: return 0
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let textColor: UIColor = (row == pickerView.selectedRow(inComponent: component)) ? .appviator : .black
        switch pickerView.tag {
            case Picker.Hotel.rawValue:
                guard !hotels.isEmpty else { return NSAttributedString(string: "") }
                return NSAttributedString(string: hotels[row], attributes: [NSAttributedString.Key.foregroundColor: textColor])
            case Picker.User.rawValue:
                if userFlag {
                    guard !users.isEmpty else { return NSAttributedString(string: "") }
                    let paragraphStyle = NSMutableParagraphStyle()
                    paragraphStyle.tabStops = [NSTextTab(textAlignment: NSTextAlignment.right, location: pickerView.rowSize(forComponent: 0).width - 20)]
                    let text = users[row].name + "\t" + (users[row].role?.rawValue ?? "")
                    return NSAttributedString(string: text, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.foregroundColor: textColor])
                } else {
                    guard !rooms.isEmpty else { return NSAttributedString(string: "") }
                    return NSAttributedString(string: rooms[row].toString, attributes: [NSAttributedString.Key.foregroundColor: textColor])
                }
            default: return NSAttributedString(string: "")
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == Picker.Hotel.rawValue {
            initUserList()
            initRoomList()
            userPicker.selectRow(0, inComponent: 0, animated: false)
            userPicker.reloadAllComponents()
        }
        pickerView.reloadComponent(component)
    }

}
