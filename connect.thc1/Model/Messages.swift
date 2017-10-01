//
//  Messages.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class Messages: NSObject {
    var senderID: String?
    //var senderName: String? // reference it
    var senderImage: String?    // ref
    var receiverID: String?
    var receiverName: String?   // ref
    var receiverImage: String? // ref
    var messageBody: String?
    var timeStamp: String?
}

var currMessage = Messages()
