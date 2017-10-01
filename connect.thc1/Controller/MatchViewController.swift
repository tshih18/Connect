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

    var userDB = FIRDatabase.database().reference().child("Users")
    
    var fetchLikedDone = false
    var fetchMatchedDone = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: "CustomChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        
        // gets liked and matched users and puts them in users[[],[]]
        fetchMatchedUsers()
        fetchLikedUsers()
        
        
        
        
        
        
        
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
                        var exists = false
                        // looped matched[]
                        for eachUser in self.users[1] {
                            if eachUser.uid == user.uid {
                                exists = true
                                print(user.name!)
                            }
                        }
                        // if not there append to liked[]
                        if exists == false {
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
                        self.users[1].append(user)
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                })
            }
        }, withCancel: nil)
    }

    
    func adjustLikedUsers() {
        // every user in matched
        print(users[1])
        for eachUser in users[1] {
            if users[0].contains(eachUser) {
                print(eachUser.name)
                // remove eachUser from users[0]
                let index = users[0].index(of: eachUser)
                users[0].remove(at: index!)
            }
        }
    }
    
    // number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users[page].count
    }
    
    // loading every cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! CustomChatCell
      
        
        
        let user = users[page][indexPath.row]
        
        cell.nameTextLabel.text = user.name
        
        
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
