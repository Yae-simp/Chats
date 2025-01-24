//
//  SignUpVC.swift
//  CocoaPods
//
//  Created by Tardes on 22/01/2025.
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
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup after loading the view can be done here.
    }
    
    @IBAction func genderSegmentedControlChanged(_ sender: UISegmentedControl) {
        let genderImages = ["genderIcon-male", "genderIcon-female", "genderIcon-other"]
        genderImageView.image = UIImage(named: genderImages[sender.selectedSegmentIndex])
    }
    
    @IBAction func createUser(_ sender: Any) {
        guard validateData() else {
            presentAlert(title: "Error", message: "Please fill in all fields correctly")
            return
        }
    
        guard let username = usernameTextField.text, let password = passwordTextField.text else { return }
        
        // Handle Firebase authentication
        Auth.auth().createUser(withEmail: username, password: password) { [weak self] authResult, error in
            if let error = error {
                self?.presentAlert(title: "Create User", message: error.localizedDescription)
            } else {
                self?.saveUserData()
            }
        }
    }
    
    func saveUserData() {
        guard let userID = Auth.auth().currentUser?.uid,
              let username = usernameTextField.text,
              let firstName = firstNameTextField.text,
              let lastName = lastNameTextField.text else { return }
        
        let birthday = dateOfBirthDatePicker.date
        let gender: Gender = {
            switch genderSegmentedControl.selectedSegmentIndex {
            case 0: return .male
            case 1: return .female
            default: return .other
            }
        }()
        
        let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: birthday, provider: .basic, profileImageUrl: nil)
        
        let db = Firestore.firestore()
        do {
                try db.collection("Users").document(userID).setData(from: user)
                // Data was written successfully, now show a success message
                presentAlert(title: "Success", message: "User created successfully") { _ in
                    self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
                }
            } catch {
                // Handle the error by showing an alert
                presentAlert(title: "Error", message: "Failed to save user data. Please try again.")
                print("Error saving user data: \(error.localizedDescription)")  // Log the error for debugging purposes
            }
    }
    
    func validateData() -> Bool {
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let repeatPassword = repeatPasswordTextField.text, !repeatPassword.isEmpty else {
            return false
        }
        
        return password == repeatPassword
    }
    
    private func presentAlert(title: String, message: String, completion: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: completion))
        self.present(alertController, animated: true, completion: nil)
    }
}
