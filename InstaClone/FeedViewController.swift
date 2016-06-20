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
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(animated: Bool) {
        self.postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            self.arrayForTable = []
            self.receivedPosts = (snap.value as? NSDictionary)!
            for (key, value) in self.receivedPosts {
                if let post = self.receivedPosts["\(key)"] as? NSDictionary {
                    let newPost = Post()
                    newPost.postedby = post["postedby"] as? String
                    newPost.statusText = post["status"] as? String
                    newPost.imageURL = post["image"] as? String
                    if let numberOfLikes = post.valueForKey("likes")?.valueForKey("number") as? Int {
                        newPost.numberOfLikes = numberOfLikes
                    }
                    if let numberOfComments = post.valueForKey("comments")?.valueForKey("number") as? Int {
                        newPost.numberOfComments = numberOfComments
                    }
                    self.arrayForTable.append(newPost)
                }
                self.tableView.reloadData()
        }
        }
    
//            self.postRef.observeEventType(.ChildAdded) { (snap: FIRDataSnapshot) in
//            let newPost = (snap.value as? NSDictionary)!
//            self.arrayForTable.append(newPost)
//                }
//        
//
//            self.tableView.reloadData()

    }
    
    
    // in view did appear, i should observe for a one time event and get .Value... then I should get child added as necessary
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! FeedTableViewCell
        
        let dictForCell = arrayForTable[indexPath.section]
        
//        cell.textLabel?.text = dictForTable["postedby"] as? String
        
        if let postedBy = dictForCell.postedby {
            if let statusText = dictForCell.statusText {
                cell.statusTextField.text = postedBy + ": " + statusText
            }
        }
        
//        let imageRef = storageRef.referenceForURL(<#T##string: String##String#>)
//        if let imageURL = dictForCell.imageURL! as? String {
//            cell.cellImageView = storageRef.child(imageURL)
        if let urlString = dictForCell.imageURL {
        cell.cellImageView.kf_setImageWithURL(NSURL(string: urlString)!)
        }
//        }
        
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
