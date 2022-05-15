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

        //Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(dismissSplash), userInfo: nil, repeats: false)

        NotificationCenter.default.addObserver(self, selector: #selector(onDbProxyReady(_:)), name: .dbProxyReady, object: nil)

        loginGenericUser()
    }

    func loginGenericUser() {
        authProxy.login(username: "appuser@appviator.com", password: "Appviator2022!") { [weak self] authData, error in
            if authData != nil && error == nil {
                self?.dbProxyReady = true
                Log.log("Logged in as default user")
                self?.dismissSplash()
            } else {
                Log.log("Cannot login as default user")
                Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { [weak self] timer in
                    Log.log("Retrying logging...")
                    self?.loginGenericUser()
                }
            }
        }
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
            appDelegate.initFromBarcode()
            appDelegate.transitionToHome(from: self)
        } else {
            appDelegate.transitionToScanner()
        }
    }
}
