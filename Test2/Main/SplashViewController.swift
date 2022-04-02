//
//  SplashViewController.swift
//  Test2
//
//  Created by maciulek on 19/05/2021.
//

import UIKit

class SplashViewController: UIViewController {
    var dbProxyReady = false
    var notReadyCounter = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)

        NotificationCenter.default.addObserver(self, selector: #selector(onDbProxyReady(_:)), name: .dbProxyReady, object: nil)

    }
    
    @objc func onDbProxyReady(_ notification: Notification) {
        dbProxyReady = true
    }

    @objc func dismissSplash() {

        if !dbProxyReady {
            notReadyCounter += 1
            Log.log(level: .ERROR, "No db connection (\(notReadyCounter))")
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)
            return
        }

        if UserDefaults.standard.bool(forKey: "resetBarcodeData") {
            UserDefaults.standard.removeObject(forKey: "barcodeData")
        }

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if !(UserDefaults.standard.string(forKey: "barcodeData")?.isEmpty ?? true) {
            appDelegate.initHotel()
            appDelegate.transitionToHome()
        } else {
            appDelegate.transitionToScanner()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
