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
    @IBOutlet var skipClientButton: UIButton!
    @IBOutlet var skipAdminButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

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

    @IBAction func skipClientButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "RitzKohSamui", "roomNumber": 9104, "guestId": "AnitaMaciek", "guestName": "Anita & Maciek", "startDate": 669364704.669543 }
        """)
    }

    @IBAction func skipAdminButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "RitzKohSamui", "roomNumber": 0, "userName": "boss", "password": "Appviator2022!" }
        """)
    }

    func found(barcodeString: String) {
        Log.log(level: .INFO, "Barcode scanned: \(barcodeString)")
        guard let b: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }
        Log.log(level: .INFO, "Barcode parsed: \(b)")

        if b.roomNumber == 0 {
            guard let userName = b.userName, let password = b.password else {
                Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
                showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
                return
            }
            UserDefaults.standard.set(barcodeString, forKey: "barcodeData")
            guest.roomNumber = 0
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.initFromBarcode()
            appDelegate.transitionToHome()
        } else {
            guard let startDate = b.startDate else {
                Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
                showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
                return
            }
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
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
