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
import FirebaseAuth
import Kingfisher
import FBSDKCoreKit

class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate, UIGestureRecognizerDelegate {
    
    let postRef = FIRDatabase.database().reference().child("posts")
    var userRef: FIRDatabaseReference?
    let storageRef = FIRStorage.storage()
    
    var receivedPosts = NSDictionary()
    var userName: String?
    var statusText: String?
    var arrayForTable: Array = [Post]()
    var contentHeight: CGFloat?
    var offsetAfterDismiss: CGFloat?
    
    var postForComment: Post?
    var tappedDict: Post?
    
    var tableScrollPosition: CGFloat = CGFloat()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadFeed()
        
        tabBarController?.delegate = self
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let offsetAfterDismiss = offsetAfterDismiss {
            tableView.contentOffset.y = offsetAfterDismiss
        }
    }
    
    func loadFeed(){
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
                    newPost.userid = post["uid"] as? String
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
    
    func commentButtonClicked(sender: UIButton) {
        postForComment = arrayForTable[sender.tag]
        
        performSegueWithIdentifier("ViewPhoto", sender: self)
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
        
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action: #selector(FeedViewController.commentButtonClicked(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let dictForCell = arrayForTable[section]
        
        let label = UILabel()
        label.tag = section
        label.userInteractionEnabled = true
        
        if let userName = dictForCell.postedby {
            label.text = userName
        }
        
        label.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.7)
        
        let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(self.handleTapped))
        tapRecognizer.delegate = self
        label.addGestureRecognizer(tapRecognizer)
        
        
        return label
    }
    
    func handleTapped(gestureRecognizer: UIGestureRecognizer) {
        
        
           let section = gestureRecognizer.view?.tag
            tappedDict = arrayForTable[section!]
        
        performSegueWithIdentifier("ToProfile", sender: self)
        offsetAfterDismiss = tableView.contentOffset.y
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayForTable.count
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ToProfile" {
        let dvc = segue.destinationViewController as! ProfileViewController
        
            dvc.userID = tappedDict?.userid
        } else if segue.identifier == "ViewPhoto" {
            let dvc = segue.destinationViewController as! PhotoDisplayViewController
            
            
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
    
    
    
}
