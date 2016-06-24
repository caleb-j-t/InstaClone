//
//  PhotoDisplayViewController.swift
//  InstaClone
//
//  Created by Cindy Barnsdale on 6/20/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase


class PhotoDisplayViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    let postRef = FIRDatabase.database().reference().child("posts").child("post2").child("comments")
    var postDict = NSDictionary()
    var user = FIRAuth.auth()?.currentUser
    var arrayOfThings = [String]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //
        postRef.observeEventType(.Value) { (snap: FIRDataSnapshot) in

//            for post in snap.children{
            self.postDict = snap.value as! NSDictionary
            for (key, _) in self.postDict {
                let comment = self.postDict["\(key)"] as? String
                if let comment = comment {
                self.arrayOfThings.append(comment)
                }
                self.tableView.reloadData()
            }
//            self.arrayOfThings.append(self.postDict)
            
//            }
            print("********")
            print(self.postDict)
            print("&&&&&&&&&")
            print(self.arrayOfThings)
        }
    
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayOfThings.count    //arrayOfThings.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CellID")
        
        let commentForCell = arrayOfThings[indexPath.row] 
        
        cell?.textLabel?.text = commentForCell
        return cell!
    }
}