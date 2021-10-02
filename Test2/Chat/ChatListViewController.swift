//
//  ChatListViewController.swift
//  Test2
//
//  Created by maciulek on 18/07/2021.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    //var chatRooms: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onChatRoomListUpdated(_:)), name: .guestUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return guest.chatRooms.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatRoomCell", for: indexPath)
        cell.textLabel?.text = guest.chatRooms[indexPath.row]
        return cell
    }

    @objc func onChatRoomListUpdated(_ notification: Notification) {
        //chatRooms = guest.chatRooms.keys.map({$0})
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        _ = pushViewController(storyBoard: "Chat", id: "Chat")
    }
}
