//
//  ChatVC.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

// Chat VC manages chat interface, displays messages, handles user input for sending messages, and updates the UI with new messages
class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    // MARK: Properties
    
    var chat: Chat?
    var list: [Message] = []
    let userID = Auth.auth().currentUser!.uid
    var listener: ListenerRegistration? = nil // A listener to track real-time message updates in the chat
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageInputView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var sendMessageButton: UIButton!
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        // Checks if `chat` is available before proceeding
        if let chat = chat {
            profileImageView.roundCorners()
            messageTextView.setBorder(width: 1, color: UIColor.lightGray.cgColor)
            messageTextView.roundCorners(radius: 5)
            messageTextView.delegate = self

            let user = chat.getOtherUser()
            self.navigationItem.title = user?.fullName()
            
            // Loads the profile image if available
            let profileImage = user?.profileImageUrl
            if let profileImage = profileImage, !profileImage.isEmpty {
                self.profileImageView.loadFrom(url: profileImage)
            } else {
                // If no profile image exists, displays a default icon
                self.profileImageView.image = UIImage(systemName: "person.circle.fill")
            }
            
            // Load messages
            //loadMessages(for: chat)
        } else {
            print("Error: Chat object is nil.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Ensures chat exists before loading messages
        if let chat = chat {
            loadMessages(for: chat)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener?.remove()
    }
    
    // MARK: TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = list[indexPath.row]
        
        let cell: MessageVCell = if item.senderId == userID {
            tableView.dequeueReusableCell(withIdentifier: "current", for: indexPath) as! MessageVCell
        } else {
            tableView.dequeueReusableCell(withIdentifier: "other", for: indexPath) as! MessageVCell
        }
        
        cell.render(message: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let item = list[indexPath.row]
        
        // height + margin + dateLabel.height
        return item.message.sizeWithFont(font: UIFont.systemFont(ofSize: 17), forWidth: 228).height + 32 + 22
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: TextView Delegate
    
    // This method is called whenever the text in the message input field changes
        func textViewDidChange(_ textView: UITextView) {
            // Disables the send button if the text view is empty (or contains only spaces)
            if textView.text!.replacingOccurrences(of: " ", with: "").isEmpty {
                sendMessageButton.isEnabled = false
            } else {
                sendMessageButton.isEnabled = true  // Enables send button if there is text
            }
            
            // Calculates the size of the text based on its content
            let size = CGSize(width: textView.frame.size.width, height: .infinity)
            let estimatedSize = textView.sizeThatFits(size)
            
            // If the text exceeds a certain height, allow scrolling
            guard textView.contentSize.height < 100 else {
                textView.isScrollEnabled = true
                return
            }
        
        textView.isScrollEnabled = false
        textView.constraints.forEach { constraint in
            if (constraint.firstAttribute == .height) {
                constraint.constant = estimatedSize.height
            }
        }
        
        messageInputView.constraints.forEach { constraint in
            if (constraint.firstAttribute == .height) {
                constraint.constant = estimatedSize.height + 16
            }
        }
    }
    
    // MARK: Data
    
    func loadMessages(for chat: Chat) {
        listener = DataManager.getMessagesListener(byChatId: chat.id) { [unowned self] messages in
            self.list = messages
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.list.count > 0 {
                    let lastIndexPath = IndexPath(item: self.list.count - 1, section: 0)
                    self.tableView.scrollToRow(at: lastIndexPath, at: .bottom, animated: false)
                }
            }
        }
    }
    
    // MARK: Actions
    
    // This action is triggered when the send message button is pressed
    @IBAction func sendMessageButton(_ sender: UIButton) {
        guard let chat = chat else { return }  // Ensure that the chat object is not nil
        let userID = Auth.auth().currentUser!.uid  // Get the current user's ID

        // Creates a new message object with the text, timestamp, sender ID, and chat ID
        let message = Message(message: messageTextView.text!, date: Date.now.timeIntervalSince1970, senderId: userID, chatId: chat.id)

        // Saves the new message to the database
        DataManager.createMessage(message)

        // Clears the text view after sending the message
        messageTextView.text = ""
        textViewDidChange(messageTextView)  // Update the send button state (enabled/disabled)
    }
}
