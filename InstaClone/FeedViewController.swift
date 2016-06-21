//
//  FeedViewController.swift
//  InstaClone
//
//  Created by Caleb Talbot on 6/19/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let postRef = FIRDatabase.database().reference().child("posts")
    let storageRef = FIRStorage.storage()
    
    var receivedPosts = NSDictionary()
    var userName: String?
    var statusText: String?
    var arrayForTable: Array = [Post]()
    var contentHeight: CGFloat?
    
    var tableScrollPosition: CGFloat = CGFloat()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.arrayForTable = []
            self.receivedPosts = (snap.value as? NSDictionary)!
            for (key, _) in self.receivedPosts {
                if let post = self.receivedPosts["\(key)"] as? NSDictionary {
                    let newPost = Post()
                    newPost.key = key as? String
                    newPost.postedby = post["postedby"] as? String
                    newPost.statusText = post["status"] as? String
                    newPost.imageURL = post["image"] as? String
                    if let numberOfLikes = post.valueForKey("likenumber") as? Int {
                        newPost.numberOfLikes = numberOfLikes
                    }
                    if let numberOfComments = post.valueForKey("comments")?.valueForKey("number") as? Int {
                        newPost.numberOfComments = numberOfComments
                    }
                    self.arrayForTable.append(newPost)
                }
                self.tableView.reloadData()
                self.tableView.contentOffset.y = self.tableScrollPosition
            }
        }
        
    }
    
   
    
    func likeButtonClicked(sender: UIButton){
       
        tableScrollPosition = tableView.contentOffset.y
        
        let buttonRow = sender.tag
        
        let dictForCell = arrayForTable[buttonRow]
        
        postRef.child(dictForCell.key!).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var post = currentData.value as? [String : AnyObject], let uid = dictForCell.postedby
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! FeedTableViewCell
        
        let dictForCell = arrayForTable[indexPath.section]
        
        if let postedBy = dictForCell.postedby {
            if let statusText = dictForCell.statusText {
                cell.statusTextField.text = postedBy + ": " + statusText
            }
        }
        
        cell.commentsTextLabel.text = "\(dictForCell.numberOfComments) comments"
        cell.likesTextLabel.text = "❤︎ \(dictForCell.numberOfLikes) likes"
        
        if let urlString = dictForCell.imageURL {
            cell.cellImageView.kf_setImageWithURL(NSURL(string: urlString)!)
        }

        cell.likeButton.tag = indexPath.section
        cell.likeButton.addTarget(self, action: #selector(FeedViewController.likeButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let dictForTable = arrayForTable[section]
        
        if let postedBy = dictForTable.postedby {
            return postedBy
        } else {
            return ""
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayForTable.count
    }
    
    
}
