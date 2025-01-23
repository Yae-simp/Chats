//
//  Chat.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import Foundation
import FirebaseAuth

struct Chat: Codable {
    var id: String
    var name: String?
    var lastMessage: Message? = nil
    var participants: [User]? = nil
    var messages: [Message]? = nil
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(String.self, forKey: .id)
        self.name = try? values.decode(String.self, forKey: .name)
    }
    
    func getOtherUser() -> User? {
        // Check if participants array is nil
        guard let participants = self.participants else {
            print("Error: Participants array is nil.")
            return nil
        }

        // Attempt to find the other user by filtering out the current user
        if let otherUser = participants.first(where: { $0.id != Auth.auth().currentUser?.uid }) {
            return otherUser
        } else {
            print("Error: Could not find another user.")
            return nil  // Return nil if no other user is found
        }
    }

    
    mutating func lastMessage () async -> Message?{
        self.lastMessage = await DataManager.getLastMessage(byChatId: self.id)
        return self.lastMessage
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
