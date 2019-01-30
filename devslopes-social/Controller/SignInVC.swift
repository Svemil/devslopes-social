//
//  ViewController.swift
//  devslopes-social
//
//  Created by Svemil DJUSIC on 4/9/18.
//  Copyright © 2018 Svemil DJUSIC. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import SwiftKeychainWrapper

class SignInVC: UIViewController {
    
    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "goToFeed", sender: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withPublishPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("JESS: Unable to authenticate with Facebook - \(String(describing: error))")
            } else if result?.isCancelled == true {
                print("JESS: User cancelled Facebook authentication")
            } else {
                print("JESS: Successfully authenticated with Facebook")
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
        
    }
    func firebaseAuth(_ credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { (user, error) in
            if error != nil {
                print("JESS: Unable to authenticate with Firebase")
            } else {
                print("JESS: Successfully authenticated with Firebase")
                
                if let user = user {
                self.complitedSingIn(id: user.uid)
                }
            }
        }
    }
    @IBAction func signInTapped(_ sender: Any) {
        
        if let email = emailField.text, let password = passwordField.text {
            Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                if error == nil {
                    print("JESS Email user authenticated with Firebase")
                } else {
                    Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error != nil {
                            print("JESS Unable to authenticated with Firebase email")
                        } else {
                            print("JESS Sucessfully authenticated with Firebase")
                        }
                    })
                }
            }
        }
        
    }
    
    func complitedSingIn(id: String) {
        let kayChainResult = KeychainWrapper.standard.set(id, forKey: KEY_UID)
        print("JESS: Data saved to keychain \(kayChainResult)")
        performSegue(withIdentifier: "goToFeed", sender: nil)
    }
    
}

