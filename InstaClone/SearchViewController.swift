//
//  SearchViewController.swift
//  InstaClone
//
//  Created by Caleb Talbot on 6/22/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import Kingfisher

class SearchViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var arrayFromSearch: Array = [Post]()
    var arrayForResults: Array = [Post]()
    let postRef = FIRDatabase.database().reference().child("posts")
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in
            let receivedPosts = (snap.value as? NSDictionary)!
            
                for (key, _) in receivedPosts {
                    if let post = receivedPosts["\(key)"] as? NSDictionary {
                        let newPost = Post()
                        
                        newPost.postedby = post["postedby"] as? String
                        newPost.statusText = post["status"] as? String
                        newPost.userid = post["uid"] as? String
                        newPost.imageURL = post["image"] as? String
                        
                        self.arrayFromSearch.append(newPost)
                    }
                }
        }
    }

    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searchPhotos(searchText)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchPhotos(searchText: String) {
        arrayForResults = []
        for post in arrayFromSearch {
            let screename = post.postedby?.lowercaseString
            let status = post.statusText?.lowercaseString
            
            if screename!.containsString(searchText.lowercaseString) == true {
                arrayForResults.append(post)
            } else if status!.containsString(searchText.lowercaseString) == true {
                arrayForResults.append(post)
            }
        }
        collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CellID", forIndexPath: indexPath) as! SearchCollectionViewCell
        
        let postForCell = arrayForResults[indexPath.row]
        
        cell.searchImageView.kf_setImageWithURL(NSURL(string: postForCell.imageURL!)!)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayForResults.count
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
}
