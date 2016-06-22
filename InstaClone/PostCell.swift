//
//  PostCell.swift
//  InstaClone
//
//  Created by Cindy Barnsdale on 6/22/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var usernameButton: UIButton!
    @IBOutlet weak var postPic: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var totalLikes: UILabel!
    @IBOutlet weak var totalComments: UILabel!
    @IBOutlet weak var commentPreviews: UITextView!
    
    override func awakeFromNib() {
        
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
