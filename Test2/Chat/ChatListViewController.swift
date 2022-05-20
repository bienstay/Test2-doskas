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
        NotificationCenter.default.addObserver(self, selector: #selector(onChatRoomListUpdated(_:)), name: .chatRoomsUpdated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onChatRoomListUpdated(_:)), name: .chatMessageUpdated, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(onChatRoomListUpdated(_:)), name: .chatMessageCountUpdated, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false, title: "Chat list")
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phoneUser.chatManager?.chatRoomCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChatListCell", for: indexPath) as! ChatListCell
        if let chatRoom = phoneUser.chatManager?.getChatRoom(indexPath.row) {
            cell.draw(chatRoom: chatRoom)
        }
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
        vc.chatRoomId = phoneUser.chatManager?.getChatRoom(indexPath.row).id
    }
}

class ChatListCell: UITableViewCell {
    @IBOutlet weak var roomNumberLabel: UILabel!
    @IBOutlet weak var assignedToLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .clear
        selectionStyle = .none
        unreadCountLabel.textColor = .red
    }

    func draw(chatRoom: ChatRoom) {
        roomNumberLabel.text = String(chatRoom.roomNumber)
        assignedToLabel.text = chatRoom.assignedTo
        if chatRoom.unreadCount > 0 {
            unreadCountLabel.text = String(chatRoom.unreadCount)
        } else {
            unreadCountLabel.text = ""
        }
    }
}
