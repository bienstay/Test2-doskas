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
    @IBOutlet var userFlagControl: UISegmentedControl!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    @IBOutlet weak var userPicker: UIPickerView! {
        didSet { userPicker.selectRow(0, inComponent: 0, animated: false) }
    }
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

        view.backgroundColor = .red
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else {
            failed()
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
        let i = userPicker.selectedRow(inComponent: 0)
        let hotelName = hotels[i].lowercased()
        dbProxy.getUsers(hotelName: hotelName) { userList in
            self.users = []
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
/*
    @IBAction func skipClientRitzButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "RitzKohSamui", "roomNumber": 9104, "startDate": 669364704.669543, "guestName": "A&M" }
        """)
    }

    @IBAction func skipClientSheratonButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "SheratonFullMoon", "roomNumber": 117, "startDate": 669364704.669543, "guestName": "Anita & Maciek" }
        """)
    }

    @IBAction func skipAdminRitzButtonPressed(_ sender: UIButton) {
        let i = userPicker.selectedRow(inComponent: 0)
        let username = users[i].email.components(separatedBy: "@")[0]
        found(barcodeString: """
            { "hotelId": "RitzKohSamui", "userName": "\(username)", "password": "Appviator2022!" }
        """)
    }

    @IBAction func skipAdminSheratonButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "SheratonFullMoon", "userName": "boss", "password": "Appviator2022!" }
        """)
    }
*/
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

/*
        if b.roomNumber == 0 {
            UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
            //guest.roomNumber = 0
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.initFromBarcode()
            appDelegate.transitionToHome()
        } else {
            // store guest data in db, when confirmed, store barcode in UserDefaults and init the app
            let guestId = Guest.formatGuestId(roomNumber: b.roomNumber, startDate: startDate)
            let guestInDb = GuestInDB(roomNumber: b.roomNumber, name: b.guestName ?? "", startDate: startDate, endDate: b.endDate ?? Date(timeInterval: 86400*7, since: startDate), phones: nil)
            dbProxy.updateGuest(hotelId: b.hotelId, guestId: guestId, guestData: guestInDb) {
                // store barcode in memory
                UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                appDelegate.initFromBarcode()
                appDelegate.transitionToHome()
            }
        }
 */
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

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 { return hotels[row] }
        else {
            let hotelName = userPicker.selectedRow(inComponent: 0)
            return userFlag ? users[row].id : rooms[hotels[hotelName]]![row].toString
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            initUserList()
        }
    }
}
