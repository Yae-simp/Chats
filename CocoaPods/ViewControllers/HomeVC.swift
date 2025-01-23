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
        
        // Sets up a listener for chat updates and update the list when new chats are received
        listener = DataManager.getChatsListener { [unowned self] chats in
            self.list = chats
            DispatchQueue.main.async {
                self.tableView.reloadData()
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
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Segues & Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newChat" {
            let navigationViewController = segue.destination as! UINavigationController
            let viewController = navigationViewController.topViewController as! NewChatVC
            
            viewController.didSelectUser = { [unowned self] user in
                self.didSelectUser(user: user)
            }
        } else if segue.identifier == "chat" {
            var chat: Chat? = nil
            if (newChatId != nil) {
                chat = list.first(where: { chat in
                    chat.id == newChatId
                })
                newChatId = nil
            } else {
                guard let indexPath = tableView.indexPathForSelectedRow else {
                    print("No chat selected")
                    return
                }
                
                chat = list[indexPath.row]
            }
            
            let viewController = segue.destination as! ChatVC
            viewController.chat = chat
        }
    }
    
    // didSelectUser is called when a user is selected for creating a new chat
    func didSelectUser(user: User) {
        // Check if chat exists with the selected user
        let existingChat = self.list.first { chat in
            chat.participants!.contains(where: { $0.id == user.id })
        }
        
        if let chat = existingChat {
            self.newChatId = chat.id
            self.performSegue(withIdentifier: "chat", sender: self)
        } else {
            Task {
                guard let newChat = await DataManager.createChat(withUser: user) else {
                    return
                }
                self.newChatId = newChat.id
                self.performSegue(withIdentifier: "chat", sender: self)
            }
        }
    }
}

