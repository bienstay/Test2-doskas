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

    var messageKitChatViewController = MessageKitChatViewController()
    var chatRoomId: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        messageKitChatViewController.chatRoomId = phoneUser.isStaff ? chatRoomId : phoneUser.id
        embed(viewController: messageKitChatViewController, inView: messageKitView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupListNavigationBar(largeTitle: false)
        title = messageKitChatViewController.chatRoomId
        //title = phoneUser.toString()
    }

    @IBAction func assignButtonPressed(_ sender: UIBarButtonItem) {
        _ = pushViewController(storyBoard: "Chat", id: "Assign")
    }
}
