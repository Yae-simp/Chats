//
//  SettingsVC.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class SettingsVC: UIViewController {
    
    @IBOutlet weak var userPicker: UIPickerView!
    
    let developmentUsers: [ChatUser] = [
        ChatUser(userId: "a95Zo3WSjDcPaEclCl2wB2SkhH93", chatId: "Chat1"),
        ChatUser(userId: "I9Kwx8AlCvZlBvTvUNfalrv8NBd2", chatId: "Chat2"),
        ChatUser(userId: "Vb1bthSvmzSH0jz3dprd48rgp832", chatId: "Chat3"),
        ChatUser(userId: "42e3SHOWO6gD0KrDSanJfM1nErE2", chatId: "Chat4"),
        ChatUser(userId: "wGxwYoDRuJP7CHlFyX7xhEMDbnY2", chatId: "Chat5"),
        ChatUser(userId: "HJDxfbUqYfNGCIF7YMCx4Fs0lJP2", chatId: "Chat6"),
        ChatUser(userId: "eDqnETuQAcRjXa4arYPsPgJ8dAB2", chatId: "Chat7"),
        ChatUser(userId: "mytEdNgsH4aA9Nuh8pyTonwzdnB3", chatId: "Chat8")
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        userPicker.dataSource = self
        userPicker.delegate = self
    }
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
}

extension SettingsVC: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return developmentUsers.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return developmentUsers[row].userId
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedUser = developmentUsers[row]
        switchToUser(withId: selectedUser.userId)
    }

    func switchToUser(withId userId: String) {
        print("Switched to user: \(userId)")
    }
}
