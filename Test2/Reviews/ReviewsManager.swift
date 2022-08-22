//
//  ReviewsManager.swift
//  Test2
//
//  Created by maciulek on 09/06/2022.
//

import Foundation

protocol ReviewsManagerDelegate: AnyObject {
    func reviewsUpdated(reviewManager: ReviewsManager)
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager)
}

class ReviewsManager {
    private var group: String = ""
    private var id: String = ""

    weak var delegate: ReviewsManagerDelegate? = nil
    var reviews: [Review] = []
    var totals: [Int] = [Int].init(repeating: 0, count: 5)  // up to 5 stars
    var count: Int { totals.reduce(0, +) }
    var scoring: Double {
        var total: Double = 0.0
        for i in 0...totals.count - 1 { total += Double(i+1)*Double(totals[i]) }
        if count > 0 { total = total / Double(count) }
        print(total)
        let total2 = totals.enumerated().reduce(0.0) { sum, value in sum + Double(value.offset + 1) * Double(value.element) }
        print(total2 / Double(count))
        return total
    }
    var translations: [String:String] = [:]

    private var reviewsPath: String { "\(group)/\(id)" }
    private var totalsPath: String { "feedback/reviews/totals/\(group)/\(id)" }
    private var translationsPath: String { "content/translations/reviews/\(group)/\(id)" }
    private var reviewsHandle: Any? = nil
    private var reviewsTotalsHandle: Any? = nil
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
        reviewsTotalsHandle = dbProxy.subscribeForUpdates(path: totalsPath, completionHandler: reviewsTotalsUpdated)
        reviewsTranslationsHandle = dbProxy.subscribeForUpdates(path: translationsPath, completionHandler: reviewsTranslationsUpdated)
    }
    
    func stop() {
        dbProxy.unsubscribe(from: reviewsHandle)
        dbProxy.unsubscribe(from: reviewsTotalsHandle)
        dbProxy.unsubscribe(from: reviewsTranslationsHandle)
    }
    
    func reviewsUpdated(allReviews: [String:Review]) {
        reviews.removeAll()
        for r in allReviews {
            // decrease rating by 1 - 1-based in DB, 0-based in app
            reviews.append(Review(id: r.key, timestamp: r.value.timestamp, rating: r.value.rating - 1, review: r.value.review, roomNumber: r.value.roomNumber, userId: r.value.userId))
        }
        reviews.sort(by: { $0.id! < $1.id! })
        delegate?.reviewsUpdated(reviewManager: self)
    }

    func reviewsTotalsUpdated(newTotals: [String:Any]) {
        guard let newTotals = newTotals as? [String:Int] else { return }
        totals = [Int].init(repeating: 0, count: 5)
        newTotals.forEach { if let index:Int = Int($0.key), index < totals.count { totals[index] = $0.value } }
        delegate?.reviewsUpdated(reviewManager: self)
        print(totals)
    }

//    func reviewsTotalsUpdated(newTotals: [String:Any]) {
//        totals = [:]
//        if let newTotals = newTotals as? [String:[Int?]] {
//            totals = newTotals.mapValues { $0.map { $0 ?? 0 } }
//        } else if let newTotals = newTotals as? [String:[String:Int]] {
//            for t in newTotals {
//                var arr:[Int] = Array<Int>(repeating: 0, count: 6)
//                for (key, value) in t.value {
//                    arr[Int(key) ?? 0] = value
//                }
//                totals[t.key] = arr
//            }
//        }
//        delegate?.reviewsUpdated(reviewManager: self)
//        print(totals)
//    }

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
