//
//  ViewController.swift
//  CocoaPods
//
//  Created by Tardes on 13/01/2025.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

class SignInVC: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Check if user is already signed in
        if Auth.auth().currentUser != nil {
            goToHome()
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        guard let username = usernameTextField.text, !username.isEmpty else {
            presentAlert(title: "Error", message: "Please enter your email.")
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: username) { error in
            if let error = error {
                print(error.localizedDescription)
                self.presentAlert(title: "Error", message: error.localizedDescription)
            } else {
                self.presentAlert(title: "Reset password", message: "We have sent an email to \(username) to reset your password")
            }
        }
    }

    @IBAction func signIn(_ sender: Any) {
        guard let email = usernameTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            presentAlert(title: "Error", message: "Please enter both email and password.")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [unowned self] authResult, error in
            if let error = error {
                print(error)
                self.presentAlert(title: "Sign In", message: error.localizedDescription)
            } else {
                print("User signs in successfully")
                if authResult?.user.isEmailVerified == true {
                    goToHome()
                } else {
                    self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
                }
            }
        }
    }

    @IBAction func googleSignIn(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil, let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    return
                }
                
                Task {
                    await self.createUser(googleUser: user)
                    DispatchQueue.main.async {
                        self.goToHome()
                    }
                }
            }
        }
    }
    
    func createUser(googleUser: GIDGoogleUser) async {
        guard let userID = Auth.auth().currentUser?.uid else { return }
        let db = Firestore.firestore()
        let docRef = db.collection("Users").document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if !document.exists {
                let username = googleUser.profile?.email ?? ""
                let firstName = googleUser.profile?.givenName ?? googleUser.profile?.name ?? ""
                let lastName = googleUser.profile?.familyName ?? ""
                let gender = Gender.unspecified
                let profileImageUrl = googleUser.profile?.hasImage == true ? googleUser.profile?.imageURL(withDimension: 200) : nil
                
                let user = User(id: userID, username: username, firstName: firstName, lastName: lastName, gender: gender, birthday: nil, provider: .google, profileImageUrl: profileImageUrl?.absoluteString)
                
                do {
                    try db.collection("Users").document(userID).setData(from: user)
                } catch let error {
                    print("Error writing user to Firestore: \(error)")
                }
            }
        } catch {
            print("Error getting document: \(error)")
        }
    }
    
    func goToHome() {
        self.performSegue(withIdentifier: "goToHome", sender: nil)
    }
    
    private func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
}


