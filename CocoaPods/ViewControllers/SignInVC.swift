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
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil {
            goToHome()
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let username = usernameTextField.text!
        Auth.auth().sendPasswordReset(withEmail: username) { error in
            if (error != nil) {
                print(error!.localizedDescription)
            }
        }
        let alert = UIAlertController(title: "Recuperar contraseña", message: "Te hemos enviado un correo a \(username) para recuperar tu contraseña.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default))
        self.present(alert, animated: true)
    }

    @IBAction func signIn(_ sender: Any) {
        Auth.auth().signIn(withEmail: usernameTextField.text!, password: passwordTextField.text!) { [unowned self] authResult, error in
          //guard let strongSelf = self else { return }
            if let error = error {
                // Hubo un error
                print(error)
                
                let alertController = UIAlertController(title: "Sign In", message: error.localizedDescription, preferredStyle: .alert)

                alertController.addAction(UIAlertAction(title: "OK", style: .default))

                self.present(alertController, animated: true, completion: nil)
            } else {
                // Todo correcto
                print("User signs in successfully")
                
                if authResult!.user.isEmailVerified {
                    goToHome()
                } else {
                    self.performSegue(withIdentifier: "navigateToEmailVerification", sender: self)
                }
            }
        }
    }

    
    @IBAction func googleSignIn(_ sender: Any) {
        // Configure Google SignIn with Firebase
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] result, error in
            guard error == nil else {
                return
            }

            guard let user = result?.user, let idToken = user.idToken?.tokenString else {
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                guard error == nil else {
                    return
                }
                
                // At this point, our user is signed in
                Task {
                    await self.createUser(googleUser: user)
                    
                    DispatchQueue.main.async {
                        //SessionManager.setSession(forUser: user.profile!.email, andPassword: "", withProvider: LoginProvider.google)
                        
                        goToHome()
                    }
                }
            }
        }
    }
    
    func createUser(googleUser: GIDGoogleUser) async {
        let userID = Auth.auth().currentUser!.uid
        
        let db = Firestore.firestore()
        
        let docRef = db.collection("Users").document(userID)
        
        do {
            let document = try await docRef.getDocument()
            if !document.exists {
                let username = googleUser.profile!.email
                let firstName = googleUser.profile!.givenName ?? googleUser.profile!.name
                let lastName = googleUser.profile!.familyName ?? ""
                //let birthday = nil
                let gender = Gender.unspecified
                let profileImageUrl = googleUser.profile!.hasImage ? googleUser.profile!.imageURL(withDimension: 200) : nil
                
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
}

