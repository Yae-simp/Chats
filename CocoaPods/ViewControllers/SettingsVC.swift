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
    
    @IBAction func signOut(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        
        self.navigationController?.navigationController?.popToRootViewController(animated: true)
    }
}
