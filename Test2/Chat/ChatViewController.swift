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
        let chatId = guest.chatRooms.first!
        messageKitChatViewController.chatRoomId = chatId
        embed(viewController: messageKitChatViewController, inView: messageKitView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.tintColor = .black
    }

}
