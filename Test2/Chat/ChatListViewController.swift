//
//  ChatListViewController.swift
//  Test2
//
//  Created by maciulek on 18/07/2021.
//

import UIKit

class ChatListViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        tableView.dataSource = self
        tableView.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(onChatRoomListUpdated(_:)), name: .guestUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false, title: "Chat list")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneUser.user!.chatManager.chatRoomCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatRoomCell", for: indexPath)
        cell.textLabel?.text = phoneUser.user!.chatManager.getChatRoom(indexPath.row).id
        cell.detailTextLabel?.text = phoneUser.user!.chatManager.getChatRoom(indexPath.row).assignedTo
        return cell
    }

    @objc func onChatRoomListUpdated(_ notification: Notification) {
        //chatRooms = guest.chatRooms.keys.map({$0})
        DispatchQueue.main.async { self.tableView.reloadData() }
    }
}

extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = pushViewController(storyBoard: "Chat", id: "Chat") as! ChatViewController
        vc.chatRoomId = phoneUser.user!.chatManager.getChatRoom(indexPath.row).id
    }
}
