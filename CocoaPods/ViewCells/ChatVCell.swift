//
//  ChatVCell.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import UIKit
import FirebaseAuth

class ChatVCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
    
    // MARK: Data
    func render(chat: Chat) {
        // Safely unwrap the 'chat' object properties to avoid force-unwrapping
        if let user = chat.getOtherUserInfo() {
            titleLabel.text = user.fullName()  // Set the user's full name as the title
        } else {
            titleLabel.text = "Unknown User"  // Fallback if there's no user data
        }
        
        // Safely unwrap lastMessage to avoid force unwrapping
        if let lastMessage = chat.lastMessage {
            subtitleLabel.text = lastMessage.message  // Set last message as subtitle
        } else {
            subtitleLabel.text = "No messages yet"  // Fallback if there's no last message
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
