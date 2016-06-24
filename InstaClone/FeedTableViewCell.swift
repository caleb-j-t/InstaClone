//
//  FeedTableViewCell.swift
//  InstaClone
//
//  Created by Caleb Talbot on 6/20/16.
//  Copyright © 2016 Caleb Talbot. All rights reserved.
//

import UIKit


class FeedTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellImageView: UIImageView!
    
    @IBOutlet weak var statusTextField: UITextView!
    
    @IBOutlet weak var commentsTextLabel: UILabel!
    
    @IBOutlet weak var likesTextLabel: UILabel!
    
    @IBOutlet weak var likeButton: UIButton!
    
    @IBOutlet weak var commentButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
