//
//  ChatViewController.swift
//  Test2
//
//  Created by maciulek on 13/07/2021.
//

import UIKit

class ChatViewController: UIViewController {

    @IBOutlet var messageKitView: UIView!
    var messageKitChatViewController = MessageKitChatViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        messageKitChatViewController.chatRoomId = guest.chatRooms.first!
        embed(viewController: messageKitChatViewController, inView: messageKitView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar()
        title = messageKitChatViewController.chatRoomId
    }

}
