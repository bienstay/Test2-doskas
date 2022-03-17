//
//  FirebaseStorage.swift
//  Test2
//
//  Created by maciulek on 17/11/2021.
//

import Foundation
import Firebase
import FirebaseStorage

extension FireB {
/*
    enum PhotoLocation {
        case BASE
        case NEWS
        case ACTIVITIES
        case RESTAURANTS
    }
*/
    var ROOT_PHOTOS_REF: StorageReference {
        return storage.reference().child("/photos")
    }

    var BASE_PHOTOS_REF: StorageReference {
        if let hotelId = hotel.id {
            return ROOT_PHOTOS_REF.child("hotels").child(hotelId)
        } else {
            return ROOT_PHOTOS_REF.child("hotels")
        }
    }

    var NEWS_PHOTOS_REF: StorageReference { BASE_PHOTOS_REF.child("news") }
    var ACTIVITIES_PHOTOS_REF: StorageReference { BASE_PHOTOS_REF.child("activities") }
    var RESTAURANTS_PHOTOS_REF: StorageReference { BASE_PHOTOS_REF.child("restaurants") }

    func uploadImage(image: UIImage, forLocation: PhotoLocation, imageName: String? = nil, completionHandler: @escaping (String) -> Void) {
        // Generate a unique ID for the post and prepare the post database reference
        var photosStorageRef = BASE_PHOTOS_REF
        switch forLocation {
            case .BASE: photosStorageRef = BASE_PHOTOS_REF
            case .NEWS: photosStorageRef = NEWS_PHOTOS_REF
            case .ACTIVITIES: photosStorageRef = ACTIVITIES_PHOTOS_REF
            case .RESTAURANTS: photosStorageRef = RESTAURANTS_PHOTOS_REF
        }

        // Use the unique key as the image name and prepare the storage reference
        //guard let imageKey = postDatabaseRef.key else { return }
        let imageKey = (imageName != nil ? imageName! : (Auth.auth().currentUser?.uid)! + "___" + Date().formatFull())
        Log.log(level: .INFO, "Uploading image with the key: " + imageKey)

        photosStorageRef = photosStorageRef.child("\(imageKey).jpg")

        // Resize the image
        let scaledImage = image.scaleTo(newWidth: 1280.0)
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {
            Log.log("failed to convert to jpeg")
            return
        }

        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        metadata.cacheControl = "public,max-age=3600"

        // Prepare the upload task
        //let uploadTask = photosStorageRef.putData(imageData, metadata: metadata) // Observe the upload status
        let uploadTask = photosStorageRef.putData(imageData) // Observe the upload status
        
        uploadTask.observe(.success) { (snapshot) in
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else { Log.log("Error getting downloadURL"); return }
                Log.log(level: .INFO, "\(url) uploaded")
                completionHandler(url.absoluteString)
            })
        }

        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete: Double = Double(100.0) * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            Log.log(level: .INFO, "Uploading \(imageKey)... \(percentComplete)% complete")
        }

        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                Log.log(level: .ERROR, "\(error)")
            }
        }
    }

}
