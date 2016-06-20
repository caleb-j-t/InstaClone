//
//  Post.swift
//  InstaClone
//
//  Created by Caleb Talbot on 6/20/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit

class Post: NSObject {

    var postedby: String?
    var statusText: String?
    var imageURL: String?
    var numberOfLikes = 0
    var namesOfLikers = [String]()
    var numberOfComments = 0
    var comments: NSDictionary?
    
}
