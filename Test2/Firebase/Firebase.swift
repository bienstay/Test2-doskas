//
//  Firebase.swift
//  Test2
//
//  Created by maciulek on 16/10/2021.
//


import Foundation
import Firebase
import FirebaseDatabase
import FirebaseStorage
import FirebaseFunctions

final class Firebase {

    static let shared: Firebase = Firebase()

    let functions: Functions
    let storage: Storage
    let auth: Auth
    let database: Database

    private init() {
        FirebaseApp.configure()
        FirebaseConfiguration.shared.setLoggerLevel(.error)

        functions = Functions.functions()
        storage = Storage.storage()
        auth = Auth.auth()
        database = Database.database()
    }

    func initialize(useEmulator: Bool) {

        if useEmulator {
            auth.useEmulator(withHost:"localhost", port:9099)
            functions.useEmulator(withHost: "localhost", port: 5001)
            storage.useEmulator(withHost: "localhost", port: 9199)
            database.useEmulator(withHost: "localhost", port: 9000)
        }
        database.isPersistenceEnabled = true
    }
}
