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
            found(code: stringValue)
        }

        //dismiss(animated: true)
    }

    @IBAction func skipButtonPressed(_ sender: UIButton) {
        found(code: """
              { "hotelId": "RitzKohSamui", "roomNumber": 9104, "guestId": "AnitaMaciek" }
              """)
//        found(code: """
//              { "hotelId": "SheratonFullMoon", "roomNumber": 117, "guestId": "MacsMaciulek" }
//              """)
    }

    func found(code: String) {
        print(code)

        guard   let params = convertJSONStringToDictionary(text: code),
                let hotelId = params["hotelId"] as? String,
                let roomNumber = params["roomNumber"] as? Int,
                let guestId = params["guestId"] as? String
        else {
            Log.log(level: .INFO, "Invalid barcode: \(code)")
            showInfoDialogBox(vc: self, title: "Invalid barcode", message: "This is not a valid barcode") { _ in self.captureSession.startRunning() }
            return
        }

        UserDefaults.standard.set(code, forKey: "barcodeData")

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.initHotel()
        appDelegate.transitionToHome()

        return;

        DispatchQueue.main.async {
            /*
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewController(withIdentifier: "MainScreen") as! UITabBarController
            UIApplication.shared.windows.first?.rootViewController = viewController
            UIApplication.shared.windows.first?.makeKeyAndVisible()
            */
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let window = UIApplication.shared.keyWindow {
                let viewController = storyboard.instantiateViewController(withIdentifier: "MainScreen")
                viewController.view.frame = window.bounds
                UIView.transition(with: window, duration: 2.0, options: .transitionCrossDissolve, animations: {
                    window.rootViewController = viewController
                }, completion: nil)
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
