//
//  MessagesViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var messagesTableView: UITableView!
    
    let currUserID = FIRAuth.auth()?.currentUser?.uid
    var messages = [Messages]()
    let userDB = FIRDatabase.database().reference().child("Users")
    let messageDB = FIRDatabase.database().reference().child("Messages")
    
    // hold the id's of everyone in messages tab
    var receiverKeys = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesTableView.register(UINib(nibName: "CustomMessageCell", bundle: nil), forCellReuseIdentifier: "customMessageCell")
        
        observeMessages()
    }
    
    
    func observeMessages() {
        
        
        /*messageDB.child(currUserID!).observe(.value, with: { (snapshot) in
  
            if let dictionary = snapshot.value as? [String: AnyObject] {
                print(dictionary)
                
                let keys = Array(dictionary.keys)
                for key in keys {
                    let length = dictionary[key]?.count
         
                    // get last message
                    print(dictionary[key]!)
                    if let lastMsg = dictionary[key] as? [String: AnyObject] {
                        print(lastMsg)
                    }
                }
                
            }
        })*/
        
        messageDB.child(currUserID!).observe(.childAdded, with: { (snapshot) in
            print(snapshot)
            
            // get the id's of people to be displayed in messages
            let receiverKey = snapshot.key
            self.receiverKeys.append(receiverKey)
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                // dictionary is not in order??????
                print(dictionary)
                
                let firstKey = Array(dictionary.keys)[0]
                
                
                // only save the most recent message of every person
                let message = Messages()

                
                message.messageBody = dictionary[firstKey]?["Message Body"] as! String?
                message.senderID = dictionary[firstKey]?["Sender ID"] as! String?
                message.timeStamp = dictionary[firstKey]?["Time"] as! String?
                message.receiverID = dictionary[firstKey]?["Receiver ID"] as! String?
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.messagesTableView.reloadData()
                }
                
            }
        
            
        }, withCancel: nil)
        
    }
    

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell
        
        let message = messages[indexPath.row]
        let receiverKey = receiverKeys[indexPath.row]
        cell.messageBody.text = message.messageBody!
        cell.timestampLabel.text = message.timeStamp!
        
        // retreve the name+image of people displayed in messages
        userDB.child(receiverKey).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                cell.nameLabel.text = dictionary["Name"] as! String?
                
                cell.senderImage.sd_setImage(with: URL(string: dictionary["ProfileImageURL"]! as! String), completed: nil)
            }
        }, withCancel: nil)
        
    
        
        
        return cell
    }
    
    // when a cell is clicked
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        currMessage.receiverID = receiverKeys[indexPath.row]
        userDB.child(currMessage.receiverID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                currMessage.receiverName = dictionary["Name"] as! String?
                currMessage.receiverImage = dictionary["ProfileImageURL"] as! String?
                
            }
        }, withCancel: nil)
        
        currMessage.senderID = currUserID
        userDB.child(currMessage.senderID!).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                currMessage.senderImage = dictionary["ProfileImageURL"] as! String?
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }, withCancel: nil)
        
    
        
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
