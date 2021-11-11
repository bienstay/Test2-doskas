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
    let translations: [String:String]?

    var sender: SenderType {
        return Sender(senderId: senderId, displayName: senderName)
    }

    var sentDate: Date {
        return timestamp
    }

    var kind: MessageKind {
        let orgColor:UIColor = senderId == guest.id ? .white : .black
        let orgAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: orgColor, .font: UIFont.systemFont(ofSize: 18)]
        let orgText = NSMutableAttributedString(string: text, attributes: orgAttributes)
        // show what has been translated to my language
        if let t = translations?[guest.lang], t != text {
            let tAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.red, .font: UIFont.systemFont(ofSize: 16)]
            let tText = NSAttributedString(string: "\n" + t, attributes: tAttributes)
            orgText.append(tText)
        } else if senderId == guest.id, let translations = translations {
        // show what the receiver had seen
            for t in translations.values {
                if t != text {
                    let tAttributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.purple, .font: UIFont.systemFont(ofSize: 16)]
                    let tText = NSAttributedString(string: "\n" + t, attributes: tAttributes)
                    orgText.append(tText)
                }
            }
        }

        return .attributedText(orgText)
//        return .text(text)
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
                messages.append(Message(senderId: m.senderID, senderName: m.senderName, text: m.content, messageId: m.id!, timestamp: m.created, translations: m.translations))
            }
            messages.sort(by: {$0.sentDate < $1.sentDate})
/*
            if let last = messages.last, last.translations?[guest.lang] == nil {
                if last.senderId != guest.id {
                    //let lang = guest.isAdmin() ? "en" : guest.lang
                    let lang = guest.lang
                    FireB.shared.translateChat(chatRoom: chatRoomId, chatID: last.messageId, textToTranslate: last.text, targetLanguage: lang, completionHandler: { _ in } )
                }
            }
*/
        }
    }
    
    func configure() {
        messageInputBar.contentView.backgroundColor = .darkGray
        messageInputBar.inputTextView.textColor = .white
        //messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        
        messageInputBar.sendButton.setTitleColor(.white, for: .normal)
        messageInputBar.sendButton.setTitleColor(.white.withAlphaComponent(0.3), for: .highlighted)
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
        _ = FireB.shared.addRecord(subNode: chatRoomId, record: newChatMessage) { _ in }
        inputBar.inputTextView.text = ""
    }
}
