//
//  User.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/9/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var age: String?
    var gender: String?
    var email: String?
    var profileImageURL: String?
    var bio: String?
    var uid: String?
    var preference = [String?](repeating: "", count:3)
    var strains = [String?](repeating: "", count:3)
    var type = [String?](repeating: "", count:4)
    var liked: [String?] = []
    var swipedRight: [String?] = []
    var matched: [String?] = []
}

var currUser = User()

