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
    var userRef: FIRDatabaseReference?

    
    var downloadURL: String?
    
    var profilePic: UIImage?
    
    @IBOutlet weak var screennameTextField: UITextField!
    @IBOutlet weak var userQuoteTextView: UITextView!
    
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var selectPictureButton: UIButton!
    
    @IBOutlet weak var profilePictureImageView: UIImageView!
    
    var loggedInUser: FIRUser?
    
    var data: NSDictionary?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loggedInUser = FIRAuth.auth()?.currentUser
        
        screennameTextField.delegate = self
        
        selectPictureButton.hidden = true
        
        if let loggedInUser = loggedInUser {
            if let displayName = loggedInUser.displayName {
            usernameTextLabel.text = displayName
            } else {
                usernameTextLabel.text = "Click the \"Edit Profile\" button to get started."
            }
         
            userRef = FIRDatabase.database().reference().child("users").child(loggedInUser.uid)
        
            userRef!.observeSingleEventOfType(.Value, withBlock: { (snap: FIRDataSnapshot) in
                self.data = snap.value as? NSDictionary
                if let data = self.data {
                    let quote = data["userquote"] as? String
                    if let quote = quote {
                        self.userQuoteTextView.text = quote
                    }
                    
                    let photoURL = data["profilepicture"] as? String
                    if let photoURL = photoURL {
                        self.profilePictureImageView.kf_setImageWithURL(NSURL(string: photoURL)!, placeholderImage: nil, optionsInfo: [.ForceRefresh])
                    }
                }
            })
           
        }
    }



    @IBAction func onEditButtonPressed(sender: AnyObject) {
        
        if sender.currentTitle == "Edit Profile" {
            
            sender.setTitle("Save", forState: UIControlState.Normal)
            screennameTextField.hidden = false
            usernameTextLabel.hidden = true
            selectPictureButton.hidden = false
            
            if let data = data {
            screennameTextField.text = data["screenname"] as? String
            }
            
            userQuoteTextView.editable = true
            
        } else {
            sender.setTitle("Edit Profile", forState: UIControlState.Normal)

            if let userRef = userRef {
                userRef.child("screenname").setValue(screennameTextField.text)
                userRef.child("userquote").setValue(userQuoteTextView.text)
         
            screennameTextField.hidden = true
            selectPictureButton.hidden = true
            usernameTextLabel.hidden = false
                if let data = data {
            usernameTextLabel.text = data["screenname"] as? String
                }
            userQuoteTextView.editable = false
        }
        
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
        let uploadRef = storageRef.child("\(loggedInUser?.uid) + profileimages")
        uploadRef.putData(data, metadata: nil) { (metadata: FIRStorageMetadata?, error: NSError?) in
            
            if error != nil {
                print("error during uploading: \(error)")
            } else {
                self.downloadURL = metadata!.downloadURL()?.absoluteString
                print(self.downloadURL!)
            }
            
            
            if let downloadURL = self.downloadURL {
                self.userRef!.child("profilepicture").setValue(downloadURL)
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
