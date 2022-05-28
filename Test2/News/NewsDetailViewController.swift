//
//  NewsDetailViewController.swift
//  Test2
//
//  Created by maciulek on 11/06/2021.
//

import UIKit

class NewsDetailViewController: UIViewController {

    var post = NewsPost()

    @IBOutlet var tableView: UITableView!
    @IBOutlet weak var deleteBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)

        tableView.delegate = self
        tableView.dataSource = self

        NotificationCenter.default.addObserver(self, selector: #selector(onLikesUpdated(_:)), name: .likesUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupTransparentNavigationBar(tableView: tableView)
    }

    override func viewWillDisappear(_ animated: Bool) {
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
}

extension NewsDetailViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section : Int) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

