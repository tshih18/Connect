//
//  CustomRightChatCell.swift
//  connect.thc1
//
//  Created by Theodore Shih on 10/3/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class CustomRightChatCell: UITableViewCell {

    @IBOutlet var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        messageLabel.layer.cornerRadius = 10
        messageLabel.layer.masksToBounds = true

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
