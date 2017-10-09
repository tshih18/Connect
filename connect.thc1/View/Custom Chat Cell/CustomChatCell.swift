//
//  CustomMessageCell.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class CustomChatCell: UITableViewCell {

    @IBOutlet var bubbleView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 260)
        bubbleViewWidthAnchor?.isActive = true
        
        imageLabel.layer.cornerRadius = 20
        imageLabel.layer.masksToBounds = true
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
