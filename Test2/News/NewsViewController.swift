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

        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = true
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black

        newPostBarButton.isEnabled = guest.isAdmin() ? true: false
        newPostBarButton.title = guest.isAdmin() ? "New" : ""
    }

    @objc func onNewsUpdated(_ notification: Notification) {
        DispatchQueue.main.async { self.tableView.reloadData() }
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
        cell.draw(post: hotel.news[indexPath.row])
        return cell
    }

}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = pushOrPresent(storyBoard: "News", id: "NewsDetail") as! NewsDetailViewController
        vc.post = hotel.news[indexPath.row]
    }
}
