//
//  MateViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/8/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class MateViewController: UIViewController {
    
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var infoTextField: UILabel!
    @IBOutlet var thumbImage: UIImageView!
    @IBOutlet var card: UIView!
    
    @IBOutlet var nextProfileImage: UIImageView!
    @IBOutlet var nextInfoTextField: UILabel!
    @IBOutlet var nextThumbImage: UIImageView!
    @IBOutlet var nextCard: UIView!
    
    var cardCenterX: CGFloat = 0
    var cardCenterY: CGFloat = 0
    
    var users = [User]()
    var userIndex1 = 0
    var userIndex2 = 1
    
    var userDB: FIRDatabaseReference!
    let currUserID = FIRAuth.auth()?.currentUser?.uid
    //let currUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // save card's original position
        cardCenterX = card.center.x
        cardCenterY = card.center.y
        
        userDB = FIRDatabase.database().reference().child("Users")
        
        // get current user's swipedright[], liked[], matched[] infos
        userDB.child(currUserID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                // if there is nothing in swiped right
                if let swipedRightString = dictionary["Swiped Right"] as? [String?] {
                    currUser.swipedRight = dictionary["Swiped Right"] as! [String?]
                }
                else {
                    currUser.swipedRight = []
                }
                
                if let likedString = dictionary["Liked"] as? [String?] {
                    currUser.liked = dictionary["Liked"] as! [String?]
                }
                else {
                    currUser.liked = []
                }

                if let matchedString = dictionary["Matched"] as? [String?] {
                    currUser.matched = dictionary["Matched"] as! [String?]
                }
                else {
                    currUser.matched = []
                }
            }
        })
 

        fetchUsers()
    }
    
    func fetchUsers() {
        userDB.observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                let user = User()
                user.name = dictionary["Name"] as! String?
                user.profileImageURL = dictionary["ProfileImageURL"] as! String?
                user.age = dictionary["Age"] as! String?
                user.gender = dictionary["Gender"] as! String?
                user.uid = dictionary["Uid"] as! String?
                
                // really hacky method -- need to change later
                var exists = false
                
                // need to change this later by initializing liked, matched, swipe as [] in viewController and signupVC
                // if liked[] has values
                /*if type(of: dictionary["Liked"]) == [String?].self || dictionary["Liked"] != "" as AnyObject as! _OptionalNilComparisonType {
                    // if only one string
                    if let likedString = dictionary["Liked"] as? String {
                        user.liked.append(dictionary["Liked"] as! String)
                    }
                    // if has many elements
                    else {
                        user.liked = dictionary["Liked"] as! [String?]
                    }
                    
                }
                // if liked[] has no values
                else {
                    user.liked = []
                }*/
                
                // replace w/ this
                if let likedString = dictionary["Liked"] as? [String?] {
                    user.liked = dictionary["Liked"] as! [String?]
                }
                else {
                    user.liked = []
                }
                
                /*if type(of: dictionary["Matched"]) == [String?].self || dictionary["Matched"] != "" as AnyObject as! _OptionalNilComparisonType {
                    // if only one string
                    if let matchedString = dictionary["Matched"] as? String {
                        user.matched.append(dictionary["Matched"] as! String)
                        
                    }
                    // if has many elements
                    else {
                        user.matched = dictionary["Matched"] as! [String?]
                    }
                }
                    // if liked[] has no values
                else {
                    user.matched = []
                }*/
                
                
                if let matchedString = dictionary["Matched"] as? [String?] {
                    user.matched = dictionary["Matched"] as! [String?]
                }
                else {
                    user.matched = []
                }
                
                // check if users has already been swipped by current user
                var alreadySwipped = false
                
                for swipes in currUser.swipedRight {
                    if swipes == user.uid {
                        alreadySwipped = true
                    }
                }
                
                // dont show current user && dont show users in swipedRight[]
                if user.uid != self.currUserID && !alreadySwipped {
                    self.users.append(user)
                    exists = true
                }
                
                if exists == true {
                // set first card info
                self.profileImage.sd_setImage(with: URL(string: self.users[0].profileImageURL!), completed: nil)
                self.infoTextField.text = self.users[0].name
                if self.users[0].age != "" {
                    self.infoTextField.text = self.infoTextField.text! + ", \(self.users[0].age!)"
                }
                if self.users[0].gender != "" {
                    self.infoTextField.text = self.infoTextField.text! + ", \(self.users[0].gender!)"
                }
                }
                
            }
        }, withCancel: nil)
    }

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func panCard(_ sender: UIPanGestureRecognizer) {
        print(sender)
        let card = sender.view!
        print(card)
        let point = sender.translation(in: view)
        let xFromCenter = card.center.x - view.center.x
        
        // tranlsate card
        card.center = CGPoint(x: cardCenterX + point.x, y: cardCenterY + point.y)
        
        // angle in radians
        let divisor = (view.frame.width/2) / 0.61
        let scale = min(100/abs(xFromCenter), 1)
        
        // rotate and scale card
        card.transform = CGAffineTransform(rotationAngle: xFromCenter/divisor).scaledBy(x: scale, y: scale)
        
        // dragged right change image and color
        if xFromCenter > 0 {
            thumbImage.image = #imageLiteral(resourceName: "thumbsUp")
            thumbImage.tintColor = UIColor.green
        }
        else {
            thumbImage.image = #imageLiteral(resourceName: "thumbsDown")
            thumbImage.tintColor = UIColor.red
        }
        
        thumbImage.alpha = abs(xFromCenter / view.center.x)
        
        // let card to back to center when touch up
        if sender.state == UIGestureRecognizerState.ended {
            // move off to left side
            if card.center.x < 75 {
                panCardLeft()
                return
            }
            // move off to right side
            else if card.center.x > (view.frame.width - 75) {
                panCardRight()
                return
            }
 
            resetCard()
    
        }
    }
    
    
    func panCardRight() {
        UIView.animate(withDuration: 0.3, animations: {
            // move card off screen x+500,y+75
            self.card.center = CGPoint(x: self.card.center.x + 50, y: self.card.center.y + 50)
        })
    }
    
    func panCardLeft() {
        UIView.animate(withDuration: 0.3, animations: {
            self.card.center = CGPoint(x: self.card.center.x - 500, y: self.card.center.y + 75)
        })
    }
    
    
    func loadNextUserOnNextCard() {
        // make images loop to beginning
        if userIndex2 == users.count - 1 {
            userIndex2 = 0
        }
        else {
            userIndex2 += 1
        }
        
        // display next user on nextCard
        self.nextProfileImage.sd_setImage(with: URL(string: self.users[userIndex2].profileImageURL!), completed: nil)
        self.nextInfoTextField.text = self.users[userIndex2].name
        if self.users[userIndex2].age != "" {
            self.nextInfoTextField.text = self.nextInfoTextField.text! + ", \(self.users[userIndex2].age!)"
        }
        if self.users[userIndex2].gender != "" {
            self.nextInfoTextField.text = self.nextInfoTextField.text! + ", \(self.users[userIndex2].gender!)"
        }
        
    }
    
    func loadNextUserOnCard() {
        // make images loop to beginning
        if userIndex1 == users.count - 1 {
            userIndex1 = 0
        }
        else {
            userIndex1 += 1
        }
    
        // display next user on Card
        self.profileImage.sd_setImage(with: URL(string: self.users[userIndex1].profileImageURL!), completed: nil)
        self.infoTextField.text = self.users[userIndex1].name
        if self.users[userIndex1].age != "" {
            self.infoTextField.text = self.infoTextField.text! + ", \(self.users[userIndex1].age!)"
        }
        if self.users[userIndex1].gender != "" {
            self.infoTextField.text = self.infoTextField.text! + ", \(self.users[userIndex1].gender!)"
        }

    }
    
    @IBAction func dislikePressed(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.loadNextUserOnNextCard()
            self.panCardLeft()
            self.loadNextUserOnCard()
        }
        
        
        DispatchQueue.main.async {
            self.card.isHidden = true
            self.card.center = CGPoint(x: self.cardCenterX, y: self.cardCenterY)
            self.view.bringSubview(toFront: self.card)
            self.card.isHidden = false
        }
        
    }
    
    
    @IBAction func likePressed(_ sender: UIButton) {
        
        // add the person's uid they liked into their Swiped Right[]
        currUser.swipedRight.append(users[userIndex1].uid!)
        userDB.child(currUserID!).child("Swiped Right").setValue(currUser.swipedRight)
        
        
        // add the current user's uid to the person's liked[] whom they swipped right
        users[userIndex1].liked.append(currUserID)
        userDB.child(users[userIndex1].uid!).child("Liked").setValue(users[userIndex1].liked)
        
        print(currUser.liked)
        // check if they match by seeing if the id that they swiped right to appears in liked[] and add to matched[]
        for element in currUser.liked {
            if element == users[userIndex1].uid {
                print(users[userIndex1].uid!)
                currUser.matched.append(users[userIndex1].uid)
                userDB.child(currUserID!).child("Matched").setValue(currUser.matched)
                
                // save curr user pid to other person's matched[]
                users[userIndex1].matched.append(currUserID)
                userDB.child(users[userIndex1].uid!).child("Matched").setValue(users[userIndex1].matched)

            }
        }
        
        self.loadNextUserOnNextCard()
        self.panCardRight()
        self.loadNextUserOnCard()

        DispatchQueue.main.async {
            self.card.isHidden = true
            self.card.center = CGPoint(x: self.cardCenterX, y: self.cardCenterY)
            self.view.bringSubview(toFront: self.card)
            self.card.isHidden = false
        }
        
    }
    
    
    @IBAction func resetCard(_ sender: UIButton) {
        resetCard()
    }
    
    
    func resetCard() {
        UIView.animate(withDuration: 0.2, animations: {
            self.card.center.y = self.view.center.y - 100
            self.card.center.x = self.view.center.x
            self.thumbImage.alpha = 0
            self.card.transform = .identity
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
