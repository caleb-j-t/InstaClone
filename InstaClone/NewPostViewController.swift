//
//  NewPostViewController.swift
//  
//
//  Created by Mike Nancett on 6/22/16.
//
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase

class NewPostViewController: UIViewController, UITextViewDelegate {
    var finalImage = UIImage(contentsOfFile: "")
    let user = FIRAuth.auth()!.currentUser
    let userID = FIRAuth.auth()!.currentUser!.uid
    let email = FIRAuth.auth()?.currentUser?.email
    let rootRefDB = FIRDatabase.database().reference()
    let rootRefStorage = FIRStorage.storage().reference()
    var photourl = ""
    var displayName = ""
    var finalData = NSData()
    var statusUpdate = "asdfjlasdfsalkj"
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.image = finalImage
        finalData = UIImageJPEGRepresentation(finalImage!, 0.5)!
    }
    
    @IBAction func postButtonPressed(sender: AnyObject) {
        saveToTheInterweb()
        statusTextView.text = "Enter a status"
    }
    
    func addPost(){
        if let aDisplayName = FIRAuth.auth()!.currentUser!.displayName{
            displayName = aDisplayName
        }

        let key = rootRefDB.child("posts").childByAutoId().key
        let post = ["uid": "\(userID)",
                    "postedby": "\(displayName)",
                    "image": "\(photourl)",
                    "status": "\(statusUpdate)"]
        
        let childUpdates = ["/posts/\(key)": post,
                            "/users/\(userID)/posts/\(key)/": post]
        rootRefDB.updateChildValues(childUpdates)
//        statusTextView.text = "Enter a status"
    }
    
    
    func textViewDidChange(textView: UITextView) {
        statusUpdate = statusTextView.text
    }

    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    @IBAction func cancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true) {
        }
    }
    
    func saveToTheInterweb(){

        let photosRef = rootRefStorage.child("\(userID)")
        let photoRef = photosRef.child("\(NSUUID().UUIDString)")
        photoRef.putData(finalData, metadata: nil) { (metadata: FIRStorageMetadata?, error: NSError?)
            in

            if error != nil {
                print("A damn Error Message")
            }else{
        self.photourl = (metadata!.downloadURL()?.absoluteString)!
                self.addPost()
            }
    }
    print(self.photourl)
    
}

}