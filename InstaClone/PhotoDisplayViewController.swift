//
//  PhotoDisplayViewController.swift
//  InstaClone
//
//  Created by Cindy Barnsdale on 6/20/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class PhotoDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    let databaseRef = FIRDatabase.database().reference().child("posts")
    var postDict = NSDictionary()
    var user = FIRAuth.auth()
    var arrayOfThings = [NSDictionary]()
    var postToDisplay: String?
    
    var tableScrollPosition: CGFloat = CGFloat()
    var arrayForTable: Array = [Post]()
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likesCount: UILabel!
    @IBOutlet weak var commentsField: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        if let postToDisplay = postToDisplay {
            
            let postRef = databaseRef.child(postToDisplay)
            
            postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
                self.arrayOfThings = []
                //            for post in snap.children{
                self.postDict = snap.value as! NSDictionary
                
                let url = self.postDict["image"] as? String
                
                if let url = url {
                    self.photoImageView.kf_setImageWithURL(NSURL(string: url)!)
                }
                
                let commentsDict = self.postDict["comments"] as? NSDictionary
                
                if let commentsDict = commentsDict {
                    
                    for (_, value) in commentsDict {
                        
                        let comment = value as? NSDictionary
                        
                        if let comment = comment {
                            self.arrayOfThings.append(comment)
                            
                        }
                        
                        self.tableView.reloadData()
                    }
                    
                    let screenname = self.postDict["postedby"]
                    if let screenname = screenname {
                        self.userButton.setTitle(screenname as? String, forState: UIControlState.Normal)
                    }
                    //
                    let likeCount = self.postDict["likenumber"]
                    if let likeCount = likeCount {
                        self.likesCount.text = "\(likeCount)"
                    }
                }
                
                //            }
                print("********")
                print(self.postDict)
                print("&&&&&&&&&")
                print(self.arrayOfThings)
            }
            
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    
    @IBAction func onLikeButtonClicked(sender: AnyObject) {
        
        var test: String?
        test = "test"
        
        databaseRef.child(postToDisplay!).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = test
                //                FIRAuth.auth()?.currentUser?.uid
            {
                var likes : Dictionary<String, Bool>
                likes = post["likedby"] as? [String : Bool] ?? [:]
                var likeCount = post["likenumber"] as? Int ?? 0
                if let _ = likes[uid] {
                    // Unstar the post and remove self from stars
                    likeCount -= 1
                    likes.removeValueForKey(uid)
                } else {
                    // Star the post and add self to stars
                    likeCount += 1
                    likes[uid] = true
                }
                post["likenumber"] = likeCount
                post["likedby"] = likes
                
                // Set value and report transaction success
                currentData.value = post
                
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
        }) { (error, committed, snapshot) in
            if let error = error {
                print(error.localizedDescription)
            }
        }

    }

    @IBAction func backButtonClicked(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func postButton(sender: AnyObject) {
        
        let comment = commentsField.text
        
        if let postToDisplay = postToDisplay {
            let commentRef = databaseRef.child(postToDisplay).child("comments")
            let key = databaseRef.child(postToDisplay).child("comments").childByAutoId().key
            let screenname = postDict["postedby"]
            if let screenname = screenname {
                let commentPost = ["comment": comment, "postedby": screenname]
                let childUpdates = ["/\(key)": commentPost]
                commentRef.updateChildValues(childUpdates)
                
            }
            
            
        }
        
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfThings.count    //arrayOfThings.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        
        let commentForCell = arrayOfThings[indexPath.row] 
        
        cell?.textLabel?.text = commentForCell["comment"] as? String
        cell?.textLabel?.numberOfLines = 0
        cell?.detailTextLabel?.text = commentForCell["postedby"] as? String
        return cell!
    }
}