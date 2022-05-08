//
//  ScannerViewController.swift
//  Test2
//
//  Created by maciulek on 26/03/2022.
//

import AVFoundation
import UIKit

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    @IBOutlet var captureView: UIView!
    @IBOutlet var skipCaptureButton: UIButton!
    @IBOutlet var defaultsStackView: UIStackView!
    @IBOutlet var userFlagControl: UISegmentedControl!
    @IBOutlet weak var userPicker: UIPickerView!
    @IBOutlet var switchButton: UIButton!

    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    //var menu:MenuView = MenuView()

    var hotels: [String] = ["RitzKohSamui", "SheratonFullMoon", "W"]
    var users: [UserData] = []
    struct RoomSample {
        var nr: Int
        var guest: String
        var toString: String { "\(nr) \(guest)" }
    }
    var rooms = [
        "RitzKohSamui" : [RoomSample(nr: 9104, guest: "A&M"), RoomSample(nr: 9205, guest: "Johnny Bravo"), RoomSample(nr: 9304, guest: "Elvis")],
        "SheratonFullMoon": [RoomSample(nr: 117, guest: "A&M"), RoomSample(nr: 223, guest: "Lola")],
        "W": [RoomSample(nr: 3, guest: "Mariola"), RoomSample(nr: 12, guest: "Anitka & Maciek")]
    ]
    var userFlag:Bool { userFlagControl.selectedSegmentIndex == 0 }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        userPicker.dataSource = self
        userPicker.delegate = self
        initUserList()

        defaultsStackView.isHidden = true
        userPicker.tintColor = .yellow
        //menu = MenuView(parentView: view, headerText: "Przykład")

        view.backgroundColor = UIColor(216, 77, 68) // rgb - taken from the color picker from log but different
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

    func initUserList() {
        users = []
        userPicker.reloadComponent(1)
        let i = userPicker.selectedRow(inComponent: 0)
        let hotelName = hotels[i].lowercased()
        dbProxy.getUsers(hotelName: hotelName) { userList in
            for u in userList {
                if let e = u["email"], let d = u["displayName"], let r = u["role"] {
                    self.users.append(UserData(email: e, displayName: d, role: .init(rawValue: r) ?? .none))
                }
            }
            DispatchQueue.main.async { self.userPicker.reloadAllComponents() }
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
        userPicker.reloadAllComponents()
    }

    @IBAction func switchButtonPressed(_ sender: UIButton) {
        captureView.isHidden = !captureView.isHidden
        captureView.isHidden ? captureSession?.stopRunning() : captureSession?.startRunning()
        defaultsStackView.isHidden = !defaultsStackView.isHidden
    }

    @IBAction func skipCaptureButtonPressed(_ sender: UIButton) {
        let hotelId = hotels[userPicker.selectedRow(inComponent: 0)]
        if userFlag {
            let userId: String = users[userPicker.selectedRow(inComponent: 1)].id
            found(barcodeString: """
            { "hotelId": "\(hotelId)", "userName": "\(userId)", "password": "Appviator2022!" }
        """)
        } else {
            let room = rooms[hotelId]![userPicker.selectedRow(inComponent: 1)]
            found(barcodeString: """
            { "hotelId": "\(hotelId)", "roomNumber": \(room.nr), "startDate": 669364704.669543, "guestName": "\(room.guest)" }
        """)
        }
    }

    func found(barcodeString: String) {
        Log.log(level: .INFO, "Barcode scanned: \(barcodeString)")
        guard let b: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession?.startRunning() }
            return
        }
        Log.log(level: .INFO, "Barcode parsed: \(b)")

        guard b.isValid() else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }

        UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initFromBarcode()
        appDelegate.transitionToHome()

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
        2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 { return hotels.count }
        else {
            let hotelName = userPicker.selectedRow(inComponent: 0)
            return userFlag ? users.count : rooms[hotels[hotelName]]!.count
        }
    }

    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let hotelName = userPicker.selectedRow(inComponent: 0)
        switch component {
        case 0: return NSAttributedString(string: hotels[row], attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        case 1: if userFlag {
                    return NSAttributedString(string: users[row].toString, attributes: [NSAttributedString.Key.foregroundColor: UIColor.pastelGreenLight])
                } else {
                    return NSAttributedString(string:
                        row < rooms[hotels[hotelName]]!.count ? rooms[hotels[hotelName]]![row].toString : "",
                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.yellow])
                }
        default: return NSAttributedString(string: "")
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            initUserList()
        }
    }
}
