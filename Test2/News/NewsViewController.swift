//
//  NewsViewController.swift
//  Test2
//
//  Created by maciulek on 19/06/2021.
//

import UIKit

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var newPostBarButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView(tableView: tableView)
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onNewsUpdated(_:)), name: .newsUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupListNavigationBar(title:.news)
        newPostBarButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        newPostBarButton.title = phoneUser.isAllowed(to: .editContent) ? "New" : ""
    }

    @objc func onNewsUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([0], with: .automatic)
            self.tableView.setNeedsLayout()
            self.tableView.endUpdates()
        }
    }

    @IBAction func newPostPressed(_ sender: Any) {
        _ = pushViewController(storyBoard: "News", id: "NewPost")
    }
}

extension NewsViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hotel.news.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsCell
        let post = hotel.news[indexPath.row]
        cell.configure(post: post)
        return cell
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard phoneUser.isAllowed(to: .editContent) else { return nil }
        let action1 = UIContextualAction(style: .normal, title: "Edit") { [weak self] action, view, completionHandler in
            if let vc = self?.createViewController(storyBoard: "News", id: "NewPost") as? NewNewsPostViewController {
                vc.postToEdit = hotel.news[indexPath.row]
                self?.navigationController?.pushViewController(vc, animated: true)
                completionHandler(true)
            }
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard phoneUser.isAllowed(to: .editContent) else { return nil }
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { [weak self] action, view, completionHandler in
            self?.deletePost(post: hotel.news[indexPath.row])
            completionHandler(true)
        }
        action1.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [action1])
//        let configuration = UISwipeActionsConfiguration(actions: [action1])
//        configuration.performsFirstActionWithFullSwipe = false
//        return configuration
    }

    func deletePost(post: NewsPost) {
        if let errStr = dbProxy.removeRecord(key: post.postId, record: post, completionHandler: { [weak self] record in
            if record == nil {
                self?.showInfoDialogBox(title: "Error", message: "Post delete failed")
            } else {
                self?.showInfoDialogBox(title: "Info", message: "Post deleted")
            }
        }) {
            Log.log(level: .ERROR, errStr)
        }
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = createViewController(storyBoard: "News", id: "NewsDetail") as? NewsDetailViewController {
            vc.post = hotel.news[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}



class NewsCell: ShadedTableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView!
    var orgFrame: CGRect? = nil

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        newsImageView.layer.cornerRadius = 8
        newsImageView.layer.masksToBounds = true
    }

    func configure(post: NewsPost) {
        titleLabel.text = post._title
        subtitleLabel.text = post._subtitle
        timestampLabel.text = post.timestamp.formatForDisplay()
        newsImageView.isHidden = true
        newsImageView.image = nil
        if let url = URL(string: post.imageFileURL) {
            newsImageView.isHidden = false
            newsImageView.kf.setImage(with: url)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if orgFrame == nil {
            orgFrame = layer.frame.inset(by: UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16));
        }
        layer.frame = orgFrame ?? .zero

        super.layoutSubviews()
    }
}


