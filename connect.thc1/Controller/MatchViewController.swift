//
//  MatchViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class MatchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var segmentedController: UISegmentedControl!
    
    let currUserID = FIRAuth.auth()?.currentUser?.uid
    
    // [[liked], [matched]]
    var users = [[User](), [User]()]
    var page = 0
    
    var keys = [String]()

    var userDB = FIRDatabase.database().reference().child("Users")
    var messageDB = FIRDatabase.database().reference().child("Messages")
    
    var fetchLikedDone = false
    var fetchMatchedDone = false
    //var keysFetched = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CustomChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")

        // gets the id's of users with messages
        getMessageKeys()
        
        // gets liked and matched users and puts them in users[[],[]]
        
        //if keysFetched == true {
        fetchMatchedUsers()
        fetchLikedUsers()
        //}
    }
    
    // find out who the user has messages with - if so dont show them on liked/matches tabs
    func getMessageKeys() {
        messageDB.child(currUserID!).observe(.childAdded, with: { (snapshot) in
            self.keys.append(snapshot.key)
            print(self.keys)
            //self.keysFetched = true
        }, withCancel: nil)
    }       
    
    // gets the users who matched with the current user by referencing their node to get updated values of name, profileImageURL
    func fetchMatchedUsers() {
        userDB.child(currUserID!).child("Matched").observe(.childAdded, with: { (snapshot) in
            if let matchedUserId = snapshot.value as? String {
                self.userDB.child(matchedUserId).observeSingleEvent(of: .value, with: { (snapshotInfo) in
                    if let matchedUserInfo = snapshotInfo.value as? [String: AnyObject] {
                        let user = User()
                        user.name = matchedUserInfo["Name"] as! String?
                        user.profileImageURL = matchedUserInfo["ProfileImageURL"] as! String?
                        user.uid = matchedUserInfo["Uid"] as! String?
                        
                        var existsInMessage = false
                        
                        for key in self.keys {
                            if user.uid == key {
                                existsInMessage = true
                                break
                            }
                        }
                        
                        if existsInMessage == false {
                            print(user.name!)
                            self.users[1].append(user)
                        }
                        
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }, withCancel: nil)
    }

    
    // gets the users who liked the current user by referencing their node to get updated values of name, profileImageURL
    func fetchLikedUsers() {
        userDB.child(currUserID!).child("Liked").observe(.childAdded, with: { (snapshot) in
            if let likedUserId = snapshot.value as? String {
                self.userDB.child(likedUserId).observeSingleEvent(of: .value, with: { (snapshotInfo) in
                    if let likedUserInfo = snapshotInfo.value as? [String: AnyObject] {
                        let user = User()
                        user.name = likedUserInfo["Name"] as! String?
                        user.profileImageURL = likedUserInfo["ProfileImageURL"] as! String?
                        user.uid = likedUserInfo["Uid"] as! String?
                        
                        
                        // maybe change how this works
                        var existsInMatched = false
                        
                        // looped matched[] to check if user appears there
                        for eachUser in self.users[1] {
                            if user.uid == eachUser.uid  {
                                existsInMatched = true
                                break
                            }
                        }
                        
                        
                        var existsInMessage = false
                        for key in self.keys {
                            if user.uid == key {
                                existsInMessage = true
                                break
                            }
                        }
                        
                        // if not in mathced[] append to liked[]
                        if existsInMatched == false && existsInMessage == false {
                            print(user.name!)
                            self.users[0].append(user)
                        }
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
            
        }, withCancel: nil)
        
    }

    
    
    // number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users[page].count
    }
    
    // loading every cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! CustomChatCell
      
        let user = users[page][indexPath.row]
        
        cell.messageLabel.text = user.name
        
        if let profileImageUrl = user.profileImageURL {
            let url = URL(string: profileImageUrl)
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                DispatchQueue.main.async {
                    cell.imageView?.image = UIImage(data: data!)
                    cell.setNeedsLayout()
                }
                
            }).resume()
        }
        
        /*
        DispatchQueue.main.async {
            cell.imageView?.sd_setImage(with: URL(string: user.profileImageURL!), completed: nil)
            cell.setNeedsLayout()
        }*/
        
        
        return cell
    }
    
    // when a cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // currMessage defines who is currently sending the message - also who receives message
        
        // already referenced from fetchLiked/MatchedUsers()
        currMessage.receiverID = users[page][indexPath.row].uid
        currMessage.receiverName = users[page][indexPath.row].name
        currMessage.receiverImage = users[page][indexPath.row].profileImageURL
        
        currMessage.senderID = currUserID
        // need to reference sender
        userDB.child(currMessage.senderID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                currMessage.senderImage = dictionary["ProfileImageURL"] as! String?
                
            }
        }, withCancel: nil)
 
        
        self.performSegue(withIdentifier: "goToChat", sender: self)
    }
    

    // when the segmented control is clicked
    @IBAction func changeTable(_ sender: UISegmentedControl) {
        page = sender.selectedSegmentIndex
        tableView.reloadData()
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
