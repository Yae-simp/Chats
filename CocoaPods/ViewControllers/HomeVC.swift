//
//  HomeVC.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

//Home VC displays a list of chats
class HomeVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    var list: [Chat] = []
    var newChatId: String? = nil
    var listener: ListenerRegistration? = nil  // A listener for monitoring real-time updates for chats

    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Sets up a listener for chat updates and updates the list when new chats are received
        listener = DataManager.getChatsListener { [weak self] chats in
            self?.list = chats
            
            // Ensure reloadData is called on the main thread
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
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
        let cell: ChatVCell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ChatVCell
        cell.render(chat: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the row
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Ensure the index is valid before accessing the list
            guard indexPath.row < list.count else { return }
            
            let chatToDelete = list[indexPath.row]
            
            // Temporarily remove the listener
            listener?.remove()
            
            // Call the deleteChat method to remove the chat from Firestore
            DataManager.deleteChat(chatToDelete) { success in
                DispatchQueue.main.async {
                    if success {
                        // Remove the chat from the local list
                        self.list.remove(at: indexPath.row)
                        
                        // Check if the list is empty
                        if self.list.isEmpty {
                            // If the list is empty, reload the table view
                            tableView.reloadData()
                        } else {
                            // Otherwise, just delete the row
                            tableView.deleteRows(at: [indexPath], with: .fade)
                        }
                    } else {
                        // Handle the error (e.g., show an alert)
                        print("Failed to delete chat.")
                    }
                    
                    // Re-add the listener if needed
                    self.listener = DataManager.getChatsListener { [weak self] chats in
                        self?.list = chats
                        DispatchQueue.main.async {
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
    }

    // MARK: Data
    // 'fetchChats' fetches the list of chats asynchronously and updates the table view
    func fetchChats() {
        Task {
            list = await DataManager.getChats()
                        tableView.reloadData()
        }
    }
    
    // MARK: Segues & Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            guard let identifier = segue.identifier else { return }
            
            if identifier == "newChat" {
                guard let navigationController = segue.destination as? UINavigationController,
                      let viewController = navigationController.topViewController as? NewChatVC else {
                    return
                }
                viewController.didSelectUser = { [weak self] user in
                    self?.initiateChatWithUser(user: user)
                }
            } else if identifier == "chat" {
                guard let viewController = segue.destination as? ChatVC else { return }
                
                var chat: Chat?
                if let newChatId = newChatId {
                    print("newChatId: \(newChatId)")
                    chat = list.first { $0.id == newChatId }
                    self.newChatId = nil
                } else if let indexPath = tableView.indexPathForSelectedRow {
                    print("list: \(list)")
                    chat = list[indexPath.row]
                }
                viewController.chat = chat
            }
        }
    
    // didSelectUser is called when a user is selected for creating a new chat
    func initiateChatWithUser(user: User) {
        // Check if chat exists with the selected user
        if let existingChat = list.first(where: { $0.participants?.contains(where: { $0.id == user.id }) ?? false }) {
            newChatId = existingChat.id
            performSegue(withIdentifier: "chat", sender: self)
        } else {
            Task {
                guard let newChat = await DataManager.createChat(withUser: user) else { return }
                newChatId = newChat.id
                performSegue(withIdentifier: "chat", sender: self)
            }
        }
    }
}

