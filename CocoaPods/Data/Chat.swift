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
    
    func getOtherUserInfo() -> User? {
        guard let participants = self.participants else {
            print("Error: Participants array is nil.")
            return nil
        }

        if let otherUser = participants.first(where: { $0.id != Auth.auth().currentUser?.uid }) {
            return otherUser
        } else {
            print("Error: Could not find another user.")
            return nil
        }
    }
    
    // This is a mutating method that fetches the last message for the chat asynchronously.
    // Call an asynchronous function to get the last message using the chat's ID.
    // This will retrieve the most recent message from the database.
    mutating func retrieveLastMessage () async -> Message?{
        self.lastMessage = await DataManager.getLastMessage(byChatId: self.id)
        return self.lastMessage
    }
    
    // A private enumeration to define the keys used for encoding and decoding the properties of the Chat struct.
    private enum CodingKeys: String, CodingKey {
        case id
        case name
    }
}
