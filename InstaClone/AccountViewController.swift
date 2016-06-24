//
//  AccountViewController.swift
//  InstaClone
//
//  Created by Caleb Talbot on 6/21/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import Kingfisher
import FBSDKCoreKit

class AccountViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    let storageRef = FIRStorage.storage().reference()
    let postRef = FIRDatabase.database().reference().child("users")
    let userRef = FIRDatabase.database().reference().child("users").child(currentUser.userID!)

    
    var downloadURL: String?
    
    var profilePic: UIImage?
    
    @IBOutlet weak var screennameTextField: UITextField!
    @IBOutlet weak var userQuoteTextView: UITextView!
    
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var selectPictureButton: UIButton!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        screennameTextField.delegate = self
        
        selectPictureButton.hidden = true
        
            if let displayName = currentUser.displayName {
            usernameTextLabel.text = displayName
            } else {
                usernameTextLabel.text = "Click the \"Edit Profile\" button to get started."
            }
         
        
        if let quote = currentUser.userQuote {
            userQuoteTextView.text = quote
        }
        
        if let photoURL = authUser?.photoURL {
        profilePictureImageView.kf_setImageWithURL(photoURL, placeholderImage: nil, optionsInfo: [.ForceRefresh])
        }
        
    }



    @IBAction func onEditButtonPressed(sender: AnyObject) {
        
        if sender.currentTitle == "Edit Profile" {
            
            sender.setTitle("Save", forState: UIControlState.Normal)
            screennameTextField.hidden = false
            usernameTextLabel.hidden = true
            selectPictureButton.hidden = false
            
            screennameTextField.text = currentUser.displayName
            
            userQuoteTextView.editable = true
            
        } else {
            sender.setTitle("Edit Profile", forState: UIControlState.Normal)
            
            let changeRequest = currentUser.authUserObject!.profileChangeRequest()
            
            changeRequest.displayName = screennameTextField.text
            
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                    print("Error during profile changeRequest: \(error)")
                } else {
                    print("Profile Updated")
                }
            }
            
            currentUser.displayName = screennameTextField.text
            currentUser.userQuote = userQuoteTextView.text

            
            userRef.child("screenname").setValue(screennameTextField.text)
            userRef.child("userquote").setValue(userQuoteTextView.text)
         
            screennameTextField.hidden = true
            selectPictureButton.hidden = true
            usernameTextLabel.hidden = false
            usernameTextLabel.text = currentUser.displayName
            
            userQuoteTextView.editable = false
        }
        
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func onProfilePickerTapped(sender: AnyObject) {
        if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            picker.allowsEditing = true
            
            picker.viewWillAppear(true)
            self.presentViewController(picker, animated: true, completion: nil)
            picker.viewDidAppear(true)
        } else {
            print("No camera available")
        }
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        let selectedImage = info[UIImagePickerControllerEditedImage] as! UIImage
        profilePictureImageView.image = selectedImage
        dismissViewControllerAnimated(true, completion: nil)
        
        saveImage(selectedImage)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func saveImage(image: UIImage) {
        let data: NSData = UIImageJPEGRepresentation(image, 0.3)!
        let uploadRef = storageRef.child("\(currentUser.userID) + profileimages")
        uploadRef.putData(data, metadata: nil) { (metadata: FIRStorageMetadata?, error: NSError?) in
            
            if error != nil {
                print("error during uploading: \(error)")
            } else {
                self.downloadURL = metadata!.downloadURL()?.absoluteString
                print(self.downloadURL!)
            }
            
            let changeRequest = currentUser.authUserObject!.profileChangeRequest()
            
            
            if let downloadURL = self.downloadURL {
                changeRequest.photoURL = NSURL(string: downloadURL)
                self.postRef.child(currentUser.userID!).child("profilepicture").setValue(downloadURL)
            }
            
            changeRequest.commitChangesWithCompletion { error in
                if let error = error {
                    print("Error during profile changeRequest: \(error)")
                } else {
                    print("Profile Updated")
                }
            }
        }
    }
    
    @IBAction func onLogOutTapped(sender: AnyObject) {
        
        try! FIRAuth.auth()!.signOut()
        
        // Facebook log out by setting access token to nil, then sending back to the initial viewcontroller.
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
        
        try! FIRAuth.auth()!.signOut()
        print("signed out")
        
        let mainStoryBoard: UIStoryboard = UIStoryboard(name: "Login", bundle: nil)
        let ViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("LoginView")
        
        self.presentViewController(ViewController, animated: true, completion: nil)
        
        
    }
    
    @IBAction func onDoneButtonPressed(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
}
