//
//  CustomMessageCell.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class CustomChatCell: UITableViewCell {

    @IBOutlet var nameTextLabel: UILabel!
    @IBOutlet var imageLabel: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        imageLabel.layer.cornerRadius = 20
        imageLabel.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
