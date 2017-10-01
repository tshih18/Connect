//
//  CustomChatCell.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class CustomMessageCell: UITableViewCell {

    @IBOutlet var senderImage: UIImageView!
    @IBOutlet var messageBody: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timestampLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        senderImage.layer.cornerRadius = 20
        senderImage.layer.masksToBounds = true
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
