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
                    self?.didSelectUser(user: user)
                }
            } else if identifier == "chat" {
                guard let viewController = segue.destination as? ChatVC else { return }
                
                var chat: Chat?
                if let newChatId = newChatId {
                    chat = list.first { $0.id == newChatId }
                    self.newChatId = nil
                } else if let indexPath = tableView.indexPathForSelectedRow {
                    chat = list[indexPath.row]
                }
                viewController.chat = chat
            }
        }
    
    // didSelectUser is called when a user is selected for creating a new chat
    func didSelectUser(user: User) {
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

