//
//  MessageKitChatViewController.swift
//  Test2
//
//  Created by maciulek on 13/07/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView


public struct Sender: SenderType {
    public let senderId: String
    public let displayName: String
}

struct Message: MessageType {
    let senderId: String
    let senderName: String
    let text: String
    let messageId: String
    let timestamp: Date

    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderName)
    }

    var sentDate: Date {
        return timestamp
    }
    
    var kind: MessageKind {
        return .text(text)
    }
}


class MessageKitChatViewController: MessagesViewController {

    var messages: [Message] = []
    var chatRoomId = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
        configure()

        NotificationCenter.default.addObserver(self, selector: #selector(onMessagesUpdated(_:)), name: .chatMessagesUpdated, object: nil)
        updateMessages()
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if self.isFirstResponder != true {
            self.becomeFirstResponder()     // this is necessary for the input view to show up
        }
    }
    
    @objc func onMessagesUpdated(_ notification: Notification) {
        updateMessages()
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToLastItem(animated: true)
    }
    
    func updateMessages() {
        messages = []
        if let msgs = guest.chatMessages?[chatRoomId] {
            for m in msgs {
                messages.append(Message(senderId: m.senderID, senderName: m.senderName, text: m.content, messageId: m.created.formatFull(), timestamp: m.created))
            }
            messages.sort(by: {$0.sentDate < $1.sentDate})
        }
    }
    
    func configure() {
        messageInputBar.contentView.backgroundColor = .pastelYellowLight
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        
        messageInputBar.sendButton.setTitleColor(.black, for: .normal)
        messageInputBar.sendButton.setTitleColor(.black.withAlphaComponent(0.3), for: .highlighted)
    }
}





extension MessageKitChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        Sender(senderId: guest.id, displayName: String(guest.Name))
    }

    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    func messageTopLabelAttributedText(for message: MessageType,at indexPath: IndexPath) -> NSAttributedString? {
        let s = NSAttributedString(string: message.sender.displayName, attributes: [.font: UIFont.preferredFont(forTextStyle: .caption1)])
        return s
    }

    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let s = NSAttributedString(string: message.sentDate.formatFriendly(), attributes: [.font: UIFont.preferredFont(forTextStyle: .caption2), .foregroundColor: UIColor.lightGray])
        return s
    }
}

extension MessageKitChatViewController: MessagesLayoutDelegate {

    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return 15
    }

    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 15
    }

}

extension MessageKitChatViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        avatarView.backgroundColor = .blue
        avatarView.isHidden = true
    }
}

extension MessageKitChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        let newChatMessage = ChatMessage(created: Date(), content: text, senderID: guest.id, senderName: guest.Name)
        let key = chatRoomId + "/" + Date().formatFull()
        _ = FireB.shared.addRecord(key: key, record: newChatMessage) { _ in }
        inputBar.inputTextView.text = ""
    }
}
