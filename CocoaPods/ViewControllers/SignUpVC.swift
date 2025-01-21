//
//  SignUpViewController.swift
//  CocoaPods
//
//  Created by Tardes on 21/01/2025.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpVC: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var dateOfBirthDatePicker: UIDatePicker!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var sUpasswordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func genderSegmentedControl(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            genderImageView.image = UIImage(named: "genderIcon-male")
        case 1:
            genderImageView.image = UIImage(named: "genderIcon-female")
        default:
            genderImageView.image = UIImage(named: "genderIcon-other")
        }
    }
    
    @IBAction func createUser(_ sender: Any) {
        let username = usernameTextField.text!
        let password = passwordTextField.text!
        
        if (validateData()) {
            Auth.auth().createUser(withEmail: username, password: password) { authResult, error in
                if let error = error {
                    // Hubo un error
                    print(error)
                    
                    let alertController = UIAlertController(title: "Create user", message: error.localizedDescription, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: "OK", style: .default))
                    
                    self.present(alertController, animated: true, completion: nil)
                } else {
                    // Todo correcto
                    print("User signs up successfully")
                    
                    self.createUser()
                }
            }
        }
    }
    
    func createUser() {
        let userID = Auth.auth().currentUser!.uid
        let username = usernameTextField.text!
        //let password = passwordTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthday = dateOfBirthDatePicker.date
        let gender = switch genderSegmentedControl.selectedSegmentIndex {
        case 0:
            Gender.male
        case 1:
            Gender.female
        default:
            Gender.other
        }
        
        let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: birthday, provider: .basic, profileImageUrl: nil)
        
        let db = Firestore.firestore()
        do {
            try db.collection("Users").document(userID).setData(from: user)
            
            let alertController = UIAlertController(title: "Create user", message: "User created successfully", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
            }))
            
            self.present(alertController, animated: true, completion: nil)
        } catch let error {
            print("Error writing user to Firestore: \(error)")
        }
    }
    
    func validateData() -> Bool {
        if firstNameTextField.text!.isEmpty {
            return false
        }
        if lastNameTextField.text!.isEmpty {
            return false
        }
        if usernameTextField.text!.isEmpty {
            return false
        }
        if passwordTextField.text!.isEmpty {
            return false
        }
        if repeatPasswordTextField.text!.isEmpty {
            return false
        }
        if passwordTextField.text != repeatPasswordTextField.text {
            return false
        }
        
        return true
    }
}
