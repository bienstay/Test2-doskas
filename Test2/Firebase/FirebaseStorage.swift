//
//  FirebaseStorage.swift
//  Test2
//
//  Created by maciulek on 17/11/2021.
//

import Foundation
import Firebase
import FirebaseStorage

final class FirebaseStorage: StorageProxy {
    static let shared: StorageProxy = FirebaseStorage()
    var ROOT_PHOTOS_REF: StorageReference {
        return Storage.storage().reference().child("/photos")
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

    private func getPhotoStorageRef(forLocation: PhotoLocation) -> StorageReference {
        let photosStorageRef: StorageReference
        switch forLocation {
            case .BASE: photosStorageRef = BASE_PHOTOS_REF
            case .NEWS: photosStorageRef = NEWS_PHOTOS_REF
            case .ACTIVITIES: photosStorageRef = ACTIVITIES_PHOTOS_REF
            case .RESTAURANTS: photosStorageRef = RESTAURANTS_PHOTOS_REF
        }
        return photosStorageRef
    }

    func uploadImage(forLocation: PhotoLocation, image: UIImage, imageName: String? = nil, completionHandler: @escaping (Error?, String?) -> Void) {
        // Generate a unique ID for the post and prepare the post database reference

        // Use the unique key as the image name and prepare the storage reference
        //guard let imageKey = postDatabaseRef.key else { return }
        let imageKey = (imageName != nil ? imageName! : (Auth.auth().currentUser?.uid)! + "___" + Date().formatFull())
        Log.log(level: .INFO, "Uploading image with the key: " + imageKey)

        let photosStorageRef = getPhotoStorageRef(forLocation: forLocation).child("\(imageKey).jpg")

        // Resize the image
        let scaledImage = image.scaleTo(newWidth: 1280.0)
        guard let imageData = scaledImage.jpegData(compressionQuality: 0.5) else {
            Log.log("failed to convert to jpeg")
            return
        }

        // Create the file metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpg"
        metadata.cacheControl = "public"

        // Prepare the upload task
        //let uploadTask = photosStorageRef.putData(imageData, metadata: metadata) // Observe the upload status
        let uploadTask = photosStorageRef.putData(imageData) // Observe the upload status
        
        uploadTask.observe(.success) { (snapshot) in
            snapshot.reference.downloadURL(completion: { (url, error) in
                guard let url = url else { Log.log("Error getting downloadURL"); return }
                Log.log(level: .INFO, "\(url) uploaded")
                completionHandler(nil, url.absoluteString)
            })
        }

        uploadTask.observe(.progress) { (snapshot) in
            let percentComplete: Double = Double(100.0) * Double(snapshot.progress!.completedUnitCount) / Double(snapshot.progress!.totalUnitCount)
            Log.log(level: .INFO, "Uploading \(imageKey)... \(percentComplete)% complete")
        }

        uploadTask.observe(.failure) { (snapshot) in
            if let error = snapshot.error {
                Log.log(level: .ERROR, "\(error)")
                completionHandler(error, nil)
            }
        }
    }

    func getImageURL(forLocation: PhotoLocation, imageName: String, completionHandler: @escaping (URL?, Error?) -> Void) {
        let photosStorageRef = getPhotoStorageRef(forLocation: forLocation).child(imageName)
        photosStorageRef.downloadURL() { url, error in
            completionHandler(url, error)
        }
    }

    func setImage(imageView: UIImageView, name: String) {
        if let url = URL(string: name) {
            imageView.kf.setImage(with: url)
        } else {
            imageView.image = nil
        }
    }

}
