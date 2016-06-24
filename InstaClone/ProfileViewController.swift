//
//  ProfileViewController.swift
//  InstaClone
//
//  Created by Cindy Barnsdale on 6/21/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKCoreKit

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profilePicture: UIImageView!
    
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var userMessage: UITextView!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var accountButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    let userRef = FIRDatabase.database().reference().child("users")
    //        .child(currentUser.userID!)
    
    var userID: String?
    
    var arrayForURLs: Array = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if userID == nil {
            if let userID = currentUser.userID {
                loadUserData(userID)
            }
            accountButton.enabled = true
            backButton.enabled = false
            backButton.tintColor = UIColor.clearColor()
        } else if userID == currentUser.userID {
            accountButton.enabled = true
            backButton.enabled = true
        } else {
            accountButton.enabled = false
            accountButton.tintColor = UIColor.clearColor()
            backButton.enabled = true
            if let userID = userID {
                loadUserData(userID)
            }
        }
        
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if let photoURL = authUser?.photoURL {
            profilePicture.kf_setImageWithURL(photoURL, placeholderImage: nil, optionsInfo: [.ForceRefresh])
        }
    }
    
    func loadUserData(userID: String) {
        
        userRef.child(userID).observeEventType(.Value) { (snap: FIRDataSnapshot) in
            
            self.arrayForURLs = []
            
            if snap.value != nil {
                let userData = snap.value as? NSDictionary
                if let userData = userData {
                    self.userNameTextLabel.text = userData["screenname"] as? String
                    self.userMessage.text = userData["userquote"] as? String
                    
                    let dictionaryOfPosts = userData["posts"] as? NSDictionary
                    if let dictionaryOfPosts = dictionaryOfPosts {
                        for (key, _) in dictionaryOfPosts {
                            if let post = dictionaryOfPosts["\(key)"] as? NSDictionary {
                                self.arrayForURLs.append((post["image"] as? String)!)
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                    })
                }
            }
        }
    }
    
    @IBAction func onBackButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID", forIndexPath: indexPath) as! ProfileCollectionViewCell
        
        let imageURL = arrayForURLs[indexPath.row]
        
        cell.cellImageView.kf_setImageWithURL(NSURL(string: imageURL)!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print("number of items in array: \(arrayForURLs.count)")
        
        return arrayForURLs.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
}
