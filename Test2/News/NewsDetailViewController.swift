//
//  NewsDetailViewController.swift
//  Test2
//
//  Created by maciulek on 11/06/2021.
//

import UIKit

class NewsDetailViewController: UIViewController {

    var post = NewsPost()
    var reviews: [Review] = []
    var translations: [String:String] = [:]
    var handle: Any? = nil

    enum Sections: Int, CaseIterable {
        case Details = 0
        case ReviewButton = 1
        case Reviews = 2
    }

    @IBOutlet var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.separatorStyle = .singleLine

        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(onLikesUpdated(_:)), name: .likesUpdated, object: nil)
        dbProxy.subscribeForUpdates(subNode: "news/\(post.postId)", parameter: nil, completionHandler: reviewsUpdated)
        handle = dbProxy.subscribeForUpdates(path: "content/translations/reviews/pl/\(post.postId)", completionHandler: reviewsTranslationsUpdated)
    }

    deinit {
        dbProxy.unsubscribe(t: Review.self, subNode: "news/\(post.postId)", parameter: nil)
        dbProxy.unsubscribe(path: "content/translations/reviews/pl/\(post.postId)")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar(tableView: tableView)
        //dbProxy.subscribeForUpdates(subNode: "news", parameter: .Review(id: post.postId), completionHandler: reviewsUpdated)
        //dbProxy.subscribeForUpdates(path: "content/translations/reviews/\(phoneUser.lang)/\(post.postId)", completionHandler: reviewsTranslationsUpdated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }

    @objc func onLikesUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .none)
            self.tableView.endUpdates()
        }
        //DispatchQueue.main.async { self.tableView.reloadData() }
    }

    func reviewsUpdated(allReviews: [String:Review]) {
        reviews = []
        for r in allReviews {
            reviews.append(Review(id: r.key, timestamp: r.value.timestamp, rating: r.value.rating, review: r.value.review, roomNumber: r.value.roomNumber, userId: r.value.userId))
        }
        reviews.sort(by: { $0.id! < $1.id! })
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .none)
            self.tableView.endUpdates()
        }
    }
    
    func reviewsTranslationsUpdated(newTranslations: [String:Any]) {
        if let newTranslations = newTranslations as? [String:[String:String]] {
            for t in newTranslations {
                if let v = t.value["review"] { translations[t.key] = v }
            }
        }
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([Sections.Reviews.rawValue], with: .none)
            self.tableView.endUpdates()
        }
    }
}

extension NewsDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        Sections.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        switch Sections(rawValue: section) {
        case .Details : return 2
        case .ReviewButton: return phoneUser.isStaff ? 0 : 1
        case .Reviews: return reviews.count
        default: return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch Sections(rawValue: indexPath.section) {
        case .Details:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsDetailHeaderCell.self), for: indexPath) as! NewsDetailHeaderCell
                cell.heartPressedClosure = { [weak self] in
                    guard let self = self else { return }
                    phoneUser.toggleLike(group: "news", key: self.post.postId)
                }
                cell.draw(post: post)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsDetailTextCell.self), for: indexPath) as! NewsDetailTextCell
                cell.draw(post: post)
                return cell
            default:
                return UITableViewCell()
            }
        case .ReviewButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewButtonCell", for: indexPath)
            cell.contentView.backgroundColor = .BBbackgroundColor
            return cell
        case .Reviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewsReviewCell", for: indexPath) as! NewsDetailReviewCell
            let r = reviews[indexPath.row]
            cell.draw(timestamp: r.timestamp, rating: r.rating, review: r.review, roomNumber: r.roomNumber, translation: translations[r.id ?? ""])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != Sections.Reviews.rawValue || reviews.isEmpty { return nil }
        return "Reviews"
    }
/*
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 { return 0 }
        return 50
    }
*/
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView, !reviews.isEmpty else { return }
        headerView.tintColor = .orange
        headerView.textLabel?.textColor = .black
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == Sections.ReviewButton.rawValue else { return }
        if let vc = self.prepareModal(storyBoard: "Activities", id: "RateReview") as? RateReviewViewController {
            vc.group = "news"
            vc.id = post.postId
            vc.reviewTitle = post.title
            vc.reviewedImage = UIImage(named: "JaNaPlaya")
            present(vc, animated: true)
        }
    }
}


class NewsDetailTextCell: UITableViewCell {

    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func draw(post: NewsPost) {
        timestampLabel.text = post.timestamp.formatForDisplay()
        postTextLabel.text = post._text
    }
}

class NewsDetailHeaderCell: UITableViewCell {

    @IBOutlet var headerImageView: UIImageView!
    @IBOutlet var headerDimmedView: UIView!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    var heartPressedClosure : (() -> ())? = nil
    
    @IBAction func heartPressed(_ sender: UIButton) {
        heartPressedClosure?()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func draw(post: NewsPost) {
        titleLabel.text = post._title
        subtitleLabel.text = post._subtitle
        if let url = URL(string: post.imageFileURL) {
            headerImageView.isHidden = false
            headerDimmedView.isHidden = false
            headerImageView.contentMode = .scaleAspectFill
            headerImageView.kf.setImage(with: url)
        } else {
            headerImageView.contentMode = .scaleAspectFit
            headerImageView.image = UIImage(named: "JaNaPlaya")
        }
        let numLikes = phoneUser.numLikes(group: "news", itemKey: post.postId)
        heartButton.setImage(UIImage(named: numLikes > 0 ? "heartFull" : "heartEmpty"), for: .normal)
    }
}

class NewsDetailReviewCell: UITableViewCell {

    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var reviewTextLabel: UILabel!
    @IBOutlet var stars: [UIImageView]!
    @IBOutlet var roomNumberLabel: UILabel!

    var emptyStar = UIImage(named: "star")
    var fullStar = UIImage(named: "star.fill")

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        if #available(iOS 13.0, *) {
            emptyStar = UIImage(systemName: "star")
            fullStar = UIImage(systemName: "star.fill")
        }
    }
    
    func draw(timestamp: Date, rating: Int, review: String, roomNumber: Int?, translation: String?) {
        timestampLabel.text = timestamp.formatForDisplay()
        let s = NSMutableAttributedString(string: review)
        if let translation = translation {
            let t = NSMutableAttributedString(string: translation, attributes: [.foregroundColor: UIColor.red])
            s.append(NSAttributedString(string: "\n"))
            s.append(t)
        }
        reviewTextLabel.attributedText = s
        for i in 0 ... stars.count - 1 {
            if i <= rating { stars[i].image = fullStar }
            else { stars[i].image = emptyStar }
        }
        if let roomNumber = roomNumber {
            roomNumberLabel.isHidden = false
            roomNumberLabel.text = String(roomNumber)
        } else {
            roomNumberLabel.isHidden = true
        }
    }
}

