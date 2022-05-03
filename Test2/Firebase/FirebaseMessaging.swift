//
//  FirebaseMessaging.swift
//  Test2
//
//  Created by maciulek on 15/04/2022.
//

import Foundation
import Firebase
import FirebaseMessaging

final class FirebaseMessaging: NSObject, MessagingDelegate, MessagingProxy {
    static let shared: FirebaseMessaging = FirebaseMessaging()

    override init() {
        super.init()
        Messaging.messaging().delegate = self
    }

    func initialize(deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Log.log(level: .INFO, "FCM Registration Token: " + (fcmToken ?? "empty token"))
    }

    func subscribeForMessages(topic: String) {
        Messaging.messaging().subscribe(toTopic: topic) { error in
            if let e = error { Log.log(level: .ERROR, e.localizedDescription) }
            else { Log.log(level: .INFO, "Subscribed to topic \(topic)") }
        }
    }
}
