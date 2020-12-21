//
//  ViewController.swift
//  IntervalChallenge
//
//  Created by Gershy Lev on 12/18/20.
//

import UIKit
import SocketIO
import MessageKit
import MessageUI
import InputBarAccessoryView

class ChatViewController: MessagesViewController {
    var user = User(senderId: UUID().uuidString, displayName: "Gershy", image: nil)
    var botUser = User(senderId: UUID().uuidString, displayName: "Bot", image: UIImage(named: "Bot")!)
    private let manager = SocketManager(socketURL: URL(string: "https://interval-takehome-chatbot.onrender.com")!, config: [.log(true), .compress,.secure(true)])
    private var socket: SocketIOClient {
        return manager.defaultSocket
    }
    private var messages: [Message] = []
    private static let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureSocketConnection()
    }

    func configureUI() {
        let barView = ChatNavigationBarView(im: botUser.image, title: botUser.displayName)
        self.navigationItem.titleView = barView
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        self.messageInputBar.inputTextView.placeholder = "Message"
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.setMessageOutgoingAvatarSize(.zero)
            layout.setMessageOutgoingMessageBottomLabelAlignment(.init(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)))
        }
    }
    
    func configureSocketConnection() {
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }

        socket.on("chat") {data, ack in
            guard let botMessage = data.first as? String else {
                return
            }
            DispatchQueue.main.async {
                let botMessage = Message(sentDate: Date(), sender: self.botUser, messageId: UUID().uuidString, kind: .text(botMessage))
                self.messages.append(botMessage)
                self.messagesCollectionView.performBatchUpdates({
                    self.messagesCollectionView.insertSections(IndexSet(integersIn: self.messages.count - 1..<self.messages.count))
                }) { (completed) in
                    self.messagesCollectionView.scrollToBottom(animated: true)
                }
            }
        }
        socket.connect()
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
    func currentSender() -> SenderType {
        return self.user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
        } else {
            avatarView.isHidden = false
            let initials = String(message.sender.firstName.prefix(1) + message.sender.lastName.prefix(1).capitalized)
            let avatar = Avatar(image: botUser.image, initials: initials)
            avatarView.set(avatar: avatar)
        }
    }
            
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        messageInputBar.inputTextView.text = String()
        socket.emit("chat", text)
        let newMessage = Message(sentDate: Date(), sender: self.user, messageId: UUID().uuidString, kind: .text(text))
        self.messages.append(newMessage)
        self.messagesCollectionView.performBatchUpdates({
            self.messagesCollectionView.insertSections(IndexSet(integersIn: self.messages.count - 1..<self.messages.count))
        }) { (completed) in
            self.messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let font = UIFont.systemFont(ofSize: 11, weight: .regular)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.darkGray,
        ]
        if indexPath.section == 0 {
            return NSAttributedString(string: message.sentDate.formatRelativeString(), attributes: attributes)
        } else {
            let previousIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let previousMessage = messageForItem(at: previousIndexPath, in: self.messagesCollectionView)
            if previousMessage.sentDate.timeIntervalSince(message.sentDate) < -3600 {
                return NSAttributedString(string: message.sentDate.formatRelativeString(), attributes: attributes)
            }
        }
        return nil
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 22
        } else {
            let previousIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let previousMessage = messageForItem(at: previousIndexPath, in: self.messagesCollectionView)
            if previousMessage.sentDate.timeIntervalSince(message.sentDate) < -3600 {
                return 22
            }
        }
        return 0
    }
    
    func cellTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment {
        return .init(textAlignment: .center, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        guard !isFromCurrentSender(message: message) else {
            return nil
        }
        if indexPath.section == 0 {
            return messageTopLabelAttributedText(displayName: message.sender.firstName)
        } else {
            let previousIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let previousMessage = messageForItem(at: previousIndexPath, in: self.messagesCollectionView)
            if previousMessage.sender.senderId != message.sender.senderId {
                return messageTopLabelAttributedText(displayName: message.sender.firstName)
            }
        }
        return nil
    }
    
    func messageTopLabelAttributedText(displayName: String) -> NSAttributedString {
        let font = UIFont.systemFont(ofSize: 11, weight: .regular)

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: UIColor.black,
        ]
        return NSAttributedString(string: displayName, attributes: attributes)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == 0 {
            return 22
        } else {
            let previousIndexPath = IndexPath(row: indexPath.row, section: indexPath.section - 1)
            let previousMessage = messageForItem(at: previousIndexPath, in: self.messagesCollectionView)
            if previousMessage.sender.senderId != message.sender.senderId {
                return 22
            }
        }
        return 0
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section == messages.count - 1 && isFromCurrentSender(message: message) {
            let font = UIFont.systemFont(ofSize: 10, weight: .regular)
            let attributes: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.darkGray,
            ]
            return NSAttributedString(string: "Delivered", attributes: attributes)
        }
        return nil
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section == messages.count - 1 && isFromCurrentSender(message: message) {
            return 20
        }
        return 0
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if isFromCurrentSender(message: message) {
            return UIColor(red: 0.16, green: 0.55, blue: 0.98, alpha: 1.00)
        }
        if #available(iOS 13, *) {
            return UIColor.systemGray5
        } else {
            return UIColor(red: 230/255, green: 230/255, blue: 235/255, alpha: 1.0)
        }
    }
}
