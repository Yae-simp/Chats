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

class SignInViewController: UIViewController {
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
                self.performSegue(withIdentifier: "goToHome", sender: nil)
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
                self.performSegue(withIdentifier: "goToHome", sender: nil)
            }
        }
    }
}


