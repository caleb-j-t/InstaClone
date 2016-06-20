//
//  LoginViewController.swift
//  InstaClone
//
//  Created by Cindy Barnsdale on 6/20/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import FBSDKLoginKit
// User FirebaseAuth to allow firebase to see users logging in.
import FirebaseAuth


class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    
    var loginButton: FBSDKLoginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.hidden = true
        
        
        // This code will check to see if the user is signed in or not. Located in firebase manage users: Step 1.
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                // If the user is signed in, show the home page.
                
                let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                let homeViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("HomeView")
                
                self.presentViewController(homeViewController, animated: true, completion: nil)
                
            } else {
                // If user is signed out, show the login button.
                
                // This is the facebook login button.
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view!.addSubview(self.loginButton)
                
                self.loginButton.hidden = false
            }
            
        }
        
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("user logged in")
        
        self.loginButton.hidden = true
        
        
        
        
        // Code to deal with users who hit cancel on the facebook login access.
        if (error != nil)
        {
            // If error occurs, login button appears
            self.loginButton.hidden = false
        }
        else if(result.isCancelled) {
            // handle the cancel event, show the login button
            self.loginButton.hidden = false
            
        } else {  // User hits OK to grant rights to use Facebook Login.
            
            // Since Firebase cannot see users logged in even with facebook set up correctly, we have to add this code. Located in guides, auth, facebook, step 4.
            
            // This is getting an access token for the signed-in user and exchanging it for a Firebase credential:
            
            let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            
            // Step 5 authenticate with Firebase using the Firebase credential
            FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
                print("user logged into firebase")
                
            }
            
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("user logged out")
    }
    
    
}

