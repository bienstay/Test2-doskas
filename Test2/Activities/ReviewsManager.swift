//
//  ReviewsManager.swift
//  Test2
//
//  Created by maciulek on 09/06/2022.
//

import Foundation

protocol ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager)
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager)
}

class ReviewsManager {
    private var group: String = ""
    private var id: String = ""

    var delegate: ReviewsManagerDelegate? = nil
    var reviews: [Review] = []
    var translations: [String:String] = [:]

    private var reviewsPath: String { "\(group)/\(id)" }
    private var translationsPath: String { "content/translations/reviews/\(group)/\(id)" }
    private var reviewsHandle: Any? = nil
    private var reviewsTranslationsHandle: Any? = nil

    init() {}

    func start(group: String, id: String) {
        self.group = group
        self.id = id
        guard !group.isEmpty && !id.isEmpty else {
            Log.log(level: .ERROR, "ReviewsManager not propaerly initialized")
            return
        }
        reviewsHandle = dbProxy.subscribeForUpdates(subNode: reviewsPath, parameter: nil, completionHandler: reviewsUpdated)
        reviewsTranslationsHandle = dbProxy.subscribeForUpdates(path: translationsPath, completionHandler: reviewsTranslationsUpdated)
    }
    
    func stop() {
        dbProxy.unsubscribe(from: reviewsHandle)
        dbProxy.unsubscribe(from: reviewsTranslationsHandle)
    }
    
    func reviewsUpdated(allReviews: [String:Review]) {
        reviews.removeAll()
        for r in allReviews {
            reviews.append(Review(id: r.key, timestamp: r.value.timestamp, rating: r.value.rating, review: r.value.review, roomNumber: r.value.roomNumber, userId: r.value.userId))
        }
        reviews.sort(by: { $0.id! < $1.id! })
        delegate?.reviewsUpdated(reviewManager: self)
    }

    func reviewsTranslationsUpdated(newTranslations: [String:Any]) {
        // key = id
        // value = reviewId/lang/review/
        if let newTranslations = newTranslations as? [String:[String:[String:String]]] {
            for t in newTranslations {
                if let v = t.value[phoneUser.lang]?["review"] {
                    translations[t.key] = v
                }
            }
        }
        delegate?.reviewsTranslationsUpdated(reviewManager: self)
    }
}
