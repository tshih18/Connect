//
//  CustomRightChatCell.swift
//  connect.thc1
//
//  Created by Theodore Shih on 10/3/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class CustomRightChatCell: UITableViewCell {
    
    @IBOutlet var bubbleView: UIView!
    @IBOutlet var messageLabel: UILabel!
    
    var bubbleViewWidthAnchor: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
        bubbleViewWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 260)
        bubbleViewWidthAnchor?.isActive = true
        
        bubbleView.layer.cornerRadius = 16
        bubbleView.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
