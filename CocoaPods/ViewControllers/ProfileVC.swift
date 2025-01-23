//
//  ProfileVC.swift
//  CocoaPods
//
//  Created by Tardes on 23/01/2025.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth

class ProfileVC: UITableViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var genderLabel: UILabel!
    
    @IBOutlet weak var dateOfBirthLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let db = Firestore.firestore()
        
        let userID = Auth.auth().currentUser!.uid
        
        let docRef = db.collection("Users").document(userID)

        Task {
            do {
                user = try await docRef.getDocument(as: User.self)
                DispatchQueue.main.async {
                    self.loadData()
                }
            } catch {
                print("Error decoding user: \(error)")
            }
        }
    }
    
    func loadData() {
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        usernameLabel.text = user.username

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if let date = user.birthday {
            dateOfBirthLabel.text = formatter.string(from: date)
        } else {
            dateOfBirthLabel.text = "--/--/----"
        }
        
        if let imageUrl = user.profileImageUrl {
            profileImageView.loadFrom(url: imageUrl)
        }
    }
}
