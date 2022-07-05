//
//  NewsDetailViewController.swift
//  Test2
//
//  Created by maciulek on 11/06/2021.
//

import UIKit

class NewsDetailViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reviewButton: UIButton!

    var post = NewsPost()
    var reviewsManager = ReviewsManager()
    enum Sections: Int, CaseIterable {
        case Details
        case Reviews
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.separatorStyle = .singleLine

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "ReviewTableViewCell", bundle: nil), forCellReuseIdentifier: "ReviewCell")

        NotificationCenter.default.addObserver(self, selector: #selector(onLikesUpdated(_:)), name: .likesUpdated, object: nil)

        reviewsManager.start(group: "news", id: post.postId)
        reviewsManager.delegate = self
    }

    deinit {
        reviewsManager.stop()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTransparentNavigationBar(tableView: tableView)
        reviewButton.isHidden = phoneUser.isStaff
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        endTransparentNavigationBar()
    }

    @objc func onLikesUpdated(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.reloadRows(at: [IndexPath(row: 0, section: Sections.Details.rawValue)], with: .none)
            self?.tableView.endUpdates()
        }
    }

    @IBAction func reviewButtonPressed(_ sender: UIButton) {
        if let vc = self.prepareModal(storyBoard: "Activities", id: "RateReview") as? RateReviewViewController {
            vc.group = "news"
            vc.id = post.postId
            vc.reviewTitle = post.title
            vc.reviewedImage = UIImage(named: "JaNaPlaya")
            present(vc, animated: true)
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
            case .Reviews: return reviewsManager.reviews.count
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
                cell.configure(post: post)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: NewsDetailTextCell.self), for: indexPath) as! NewsDetailTextCell
                cell.configure(post: post)
                return cell
            default:
                return UITableViewCell()
            }
        case .Reviews:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! ReviewTableViewCell
            let r = reviewsManager.reviews[indexPath.row]
            cell.draw(timestamp: r.timestamp, rating: r.rating, review: r.review, roomNumber: r.roomNumber, translation: reviewsManager.translations[r.id ?? ""])
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section != Sections.Reviews.rawValue || reviewsManager.reviews.isEmpty { return nil }
        return "Reviews"
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == Sections.Details.rawValue { return 40 }
        else { return 0 }
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView, !reviewsManager.reviews.isEmpty else { return }
        headerView.tintColor = .orange
        headerView.textLabel?.textColor = .black
    }
}

extension NewsDetailViewController: ReviewsManagerDelegate {
    func reviewsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections([Sections.Reviews.rawValue], with: .fade)
            self?.tableView.endUpdates()
        }
    }
    
    func reviewsTranslationsUpdated(reviewManager: ReviewsManager) {
        DispatchQueue.main.async { [weak self] in
            self?.tableView.beginUpdates()
            self?.tableView.reloadSections([Sections.Reviews.rawValue], with: .fade)
            self?.tableView.endUpdates()
        }
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

    func configure(post: NewsPost) {
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

class NewsDetailTextCell: UITableViewCell {

    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var postTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
    }
    
    func configure(post: NewsPost) {
        timestampLabel.text = post.timestamp.formatForDisplay()
        postTextLabel.text = post._text
    }
}
