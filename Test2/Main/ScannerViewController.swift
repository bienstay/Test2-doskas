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
    @IBOutlet var skipButton: UIButton!
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

        view.backgroundColor = .red
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
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
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
        tabBarController?.tabBar.isHidden = true

        if (captureSession?.isRunning == false) {
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

        //dismiss(animated: true)
    }

    @IBAction func skipButtonPressed(_ sender: UIButton) {
        found(barcodeString: """
            { "hotelId": "RitzKohSamui", "roomNumber": 9104, "guestId": "AnitaMaciek", "guestName": "Anita & Maciek", "startDate": 669364704.669543 }
        """)
    }

    func found(barcodeString: String) {
        Log.log(level: .INFO, "Barcode scanned: \(barcodeString)")

/*
        guard   let params = convertJSONStringToDictionary(text: code),
                let hotelId = params["hotelId"] as? String,
                let roomNumber = params["roomNumber"] as? Int,
                let guestId = params["guestId"] as? String
        else {
            Log.log(level: .INFO, "Invalid barcode: \(code)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }
        Log.log(level: .INFO, "Barcode: hotelId=\(hotelId), roomNumber=\(roomNumber), guestId=\(guestId)")
        UserDefaults.standard.set(code, forKey: "barcodeData")
*/
        guard let b: BarcodeData = parseJSON(barcodeString) else {
            Log.log(level: .INFO, "Invalid barcode: \(barcodeString)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }
        Log.log(level: .INFO, "Barcode parsed: \(b)")

        hotel.id = b.hotelId

        // store guest data in db
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let guestId = appDelegate.formatGuestId(barcodeData: b)
        let guestInDb = GuestInDB(roomNumber: b.roomNumber, name: b.guestName ?? "", startDate: b.startDate, endDate: b.endDate ?? Date(timeInterval: 86400*7, since: b.startDate), phones: nil)
        dbProxy.updateGuest(guestId: guestId, guestData: guestInDb)

        // store barcode in memory - TODO - do it in a completion of dxproxy.updateGuest
        UserDefaults.standard.set(barcodeString, forKey: "barcodeData")

        appDelegate.initHotel()
        appDelegate.transitionToHome()
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
