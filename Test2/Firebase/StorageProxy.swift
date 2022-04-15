//
//  StorageProxy.swift
//  Test2
//
//  Created by maciulek on 14/04/2022.
//

import Foundation
import UIKit
import Kingfisher

enum PhotoLocation {
    case BASE
    case NEWS
    case ACTIVITIES
    case RESTAURANTS
}

protocol StorageProxy {
    func uploadImage(forLocation: PhotoLocation, image: UIImage, imageName: String?, completionHandler: @escaping (String) -> Void)
    //func getImageURL(forLocation: PhotoLocation, imageName: String) -> String
    func getImageURL(forLocation: PhotoLocation, imageName: String, completionHandler: @escaping (URL?, Error?) -> Void)
    func setImage(imageView: UIImageView, name: String)
}

