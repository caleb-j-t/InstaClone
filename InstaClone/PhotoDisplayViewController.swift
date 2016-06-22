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


class PhotoDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let postRef = FIRDatabase.database().reference().child("posts")
    let storageRef = FIRStorage.storage()
    
    @IBOutlet weak var tableView: UITableView!
    
    var receivedPosts = NSDictionary()
    var userName: String?
    var statusText: String?
    var arrayForTable: Array = [Post]()
    var contentHeight: CGFloat?
    var tableScrollPosition: CGFloat = CGFloat()
    
    var dateArray = [NSDate?]()
    var picArray = [UIImage]()
    var titleArray = [String]()
 
    
    
    



 
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Photo View"
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 450

        
        refresh()

// Swipe gesture to go back a page.
        
//        let swiperight: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(LoginViewController.swiperight(_:)))
//        swiperight.direction = .Right
//        self.view!.addGestureRecognizer(swiperight)
    

    
    
    
    
    }
    
    override func viewDidAppear(animated: Bool) {
        
        // Retrieving data with observeEventType
        self.postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.arrayForTable = []
            // Are we retrieving a string or array?
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
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID", forIndexPath: indexPath) as! PostCell
        
        let dictForCell = arrayForTable[indexPath.section]
        
        if let postedBy = dictForCell.postedby {
            if let statusText = dictForCell.statusText {
                cell.commentPreviews.text = postedBy + ": " + statusText
            }
        }
        
        cell.totalComments.text = "\(dictForCell.numberOfComments) comments"
        cell.totalLikes.text = "❤︎ \(dictForCell.numberOfLikes) likes"
        
        if let urlString = dictForCell.imageURL {
            cell.postPic.kf_setImageWithURL(NSURL(string: urlString)!)
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
        // #warning Incomplete implementation, return the number of rows
        
        return 1
      //  return usernameArray.count

    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return arrayForTable.count
    }
    
    

    
    
    func refresh() {
        tableView.reloadData()
    }
    
    func goBack() {
//        let profileViewController: UIViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ProfileView")
//        
//        self.presentViewController(profileViewController, animated: true, completion: nil)
}

    
    func swiperight(gestureRecognizer: UISwipeGestureRecognizer) {
        //Do what you want here to go back
        
    goBack()
        
    }

    @IBAction func userNameButtonTapped(sender: AnyObject) {
        
     
    goBack()
    
    }
    @IBAction func heartButtonTapped(sender: AnyObject) {
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
