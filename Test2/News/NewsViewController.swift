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
        NotificationCenter.default.addObserver(self, selector: #selector(onNewsUpdated(_:)), name: .likesUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
        title = .news
        newPostBarButton.isEnabled = phoneUser.isAllowed(to: .editContent)
        newPostBarButton.title = phoneUser.isAllowed(to: .editContent) ? "New" : ""
    }

    @objc func onNewsUpdated(_ notification: Notification) {
        DispatchQueue.main.async {
            self.tableView.beginUpdates()
            self.tableView.reloadSections([0], with: .none)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell2", for: indexPath) as! NewsCell
        let post = hotel.news[indexPath.row]
/*
        let numLikes: Int
        if phoneUser.isStaff {
            numLikes = hotel.likes["news"]?[post.postId] ?? 0
        } else {
            let found = phoneUser.guest?.likes["news"]?.contains(post.postId)
            numLikes = found ?? false ? 1 : 0
        }
*/
        cell.draw(post: post, numLikes: phoneUser.numLikes(group: "news", itemKey: post.postId))
        return cell
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .normal, title: "Edit") { action, view, completionHandler in
            let vc = self.createViewController(storyBoard: "News", id: "NewPost") as! NewNewsPostViewController
            vc.postToEdit = hotel.news[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
            completionHandler(true)
        }
        action1.backgroundColor = .orange
        return UISwipeActionsConfiguration(actions: [action1])
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if !phoneUser.isAllowed(to: .editContent) { return nil }
        let action1 = UIContextualAction(style: .destructive, title: "Delete") { action, view, completionHandler in
            self.deletePost(post: hotel.news[indexPath.row])
            completionHandler(true)
        }
        action1.backgroundColor = .red
        let configuration = UISwipeActionsConfiguration(actions: [action1])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }

    func deletePost(post: NewsPost) {
        let errStr = dbProxy.removeRecord(key: post.postId, record: post) { record in
            if record == nil {
                self.showInfoDialogBox(title: "Error", message: "Post delete failed")
            } else {
                self.showInfoDialogBox(title: "Info", message: "Post deleted")
            }
        }
        if errStr != nil { Log.log(errStr!) }
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = pushOrPresent(storyBoard: "News", id: "NewsDetail") as! NewsDetailViewController
        vc.post = hotel.news[indexPath.row]
    }
}

