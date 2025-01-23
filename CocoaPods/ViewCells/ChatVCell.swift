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
    
    @IBOutlet var profileImageView: UIImageView!
    
    @IBOutlet weak var messagesLabel: UILabel!
    
    // MARK: Data
    
    func render(chat: Chat) {
        titleLabel.text = chat.name
        //titleLabel.sizeToFit()
        
        let user = chat.getOtherUser()
        self.titleLabel.text = user.fullName()
        _ = user.profileImageUrl

        
        var lastMessageText = ""
        if chat.lastMessage != nil {
            lastMessageText = chat.lastMessage!.message
        }
        self.subtitleLabel.text = lastMessageText
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
