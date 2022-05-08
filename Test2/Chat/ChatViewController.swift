//
//  ChatViewController.swift
//  Test2
//
//  Created by maciulek on 13/07/2021.
//

import UIKit

class ChatViewController: UIViewController {
    @IBOutlet var messageKitView: UIView!
    @IBOutlet weak var assignButton: UIBarButtonItem!

    private var messageKitChatViewController = MessageKitChatViewController()
    var chatRoomId: String?
    private var chatRoom: ChatRoom?

    override func viewDidLoad() {
        super.viewDidLoad()
        if let id = chatRoomId, phoneUser.isStaff, let chatRoom = phoneUser.chatRoom(charRoom: id) {
            self.chatRoom = chatRoom
        } else if let chatRoom = phoneUser.chatRoom() {
            self.chatRoom = chatRoom
        }
        //chatRoom = phoneUser.isStaff ? chatRoom : phoneUser.chatRoom(id)
        messageKitChatViewController.chatRoom = chatRoom
        //messageKitChatViewController.chatRoomId = phoneUser.isStaff ? chatRoomId : phoneUser.id
        embed(viewController: messageKitChatViewController, inView: messageKitView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        inChatWindow = true

        setupListNavigationBar(largeTitle: false)
        title = String(chatRoom?.roomNumber ?? 0)
        if let chatRoom = chatRoom {
            title = "\(chatRoom.roomNumber) - \(chatRoom.assignedTo)"
        }
        assignButton.isEnabled = phoneUser.isStaff
        assignButton.tintColor = phoneUser.isStaff ? nil : .clear
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        inChatWindow = false
    }
    
    @IBAction func assignButtonPressed(_ sender: UIBarButtonItem) {
        guard let chatRoom = chatRoom else { return }
        let vc = pushViewController(storyBoard: "Chat", id: "Assign") as! AssignViewController
        vc.chatRoom = chatRoom.id
    }
}
