//
//  ChatViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/24/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UITextFieldDelegate {


    @IBOutlet var inputTextField: UITextField!
    @IBOutlet var sendButton: UIButton!
    
    @IBOutlet var chatImage: UIImageView!
    @IBOutlet var chatName: UILabel!
    
    @IBOutlet var chatTableView: UITableView!
    
    
    // setup reference
    let currUserID = FIRAuth.auth()?.currentUser?.uid
    let userDB = FIRDatabase.database().reference().child("Users")
    let messagesDB = FIRDatabase.database().reference().child("Messages")

    
    var messages = [Messages]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextField.delegate = self
        
        // register custom table view
        chatTableView.register(UINib(nibName: "CustomChatCell", bundle: nil), forCellReuseIdentifier: "customChatCell")
        chatTableView.register(UINib(nibName: "CustomRightChatCell", bundle: nil), forCellReuseIdentifier: "customRightChatCell")

        chatTableView.separatorStyle = .none
        
        chatImage.layer.cornerRadius = 20
        chatImage.layer.masksToBounds = true
        
        chatName.text = currMessage.receiverName
        chatImage.sd_setImage(with: URL(string: currMessage.receiverImage!), completed: nil)
        retrieveMessages()

    }
    
    // dynamically set height for each chat message
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 80
        if let text = messages[indexPath.row].messageBody {
            height = estimateFrameForText(text: text).height + 32
        }
        return height
    }
    
    func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 260, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        // modify width - need reference to width anchor

        // if own message, use CustomRightChatCell
        if message.senderID == currUserID {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customRightChatCell", for: indexPath) as! CustomRightChatCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: message.messageBody!).width + 30
            cell.messageLabel.text = message.messageBody
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "customChatCell", for: indexPath) as! CustomChatCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.bubbleViewWidthAnchor?.constant = estimateFrameForText(text: message.messageBody!).width + 30
            cell.messageLabel.text = message.messageBody
            // reference database to get updated images for sender and receiver
            userDB.child(message.senderID!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    cell.imageLabel.sd_setImage(with: URL(string: dictionary["ProfileImageURL"] as! String), completed: nil)
                }
            }, withCancel: nil)
            
            return cell

        }
        
        
    }
    
    
    func retrieveMessages() {
        messagesDB.child(currUserID!).child(currMessage.receiverID!).observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: String] {
                let message = Messages()
                message.messageBody = dictionary["Message Body"]
                message.senderID = dictionary["Sender ID"]
                message.receiverID = dictionary["Receiver ID"]
                
                self.messages.append(message)
                
                DispatchQueue.main.async {
                    self.chatTableView.reloadData()
                }
            }
        })
    }
    
    var sentTime = ""

    // get current time when message is sent
    func getTime() {
        let date = Date()
        let calendar = Calendar.current
        var hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        var minute = "\(minutes)"
        
        
        // account for single digit minutes
        if minutes < 10 {
            minute = "0\(minutes)"
        }
        
        // non-military time
        if hour > 12 {
            hour -= 12
            sentTime = "\(hour):\(minute) PM"
        }
        else {
            sentTime = "\(hour):\(minute) AM"
        }

    }
    
    
    //MARK: Send Button Pressed
    @IBAction func sendPressed(_ sender: UIButton) {
        // disable send and text field
        inputTextField.isEnabled = false
        sendButton.isEnabled = false
        
        getTime()
    
        handleSend(sentTime: sentTime)
        
        // re-enable fields
        self.inputTextField.isEnabled = true
        self.sendButton.isEnabled = true
        self.inputTextField.text = ""
    }
    
    func handleSend(sentTime: String) {
        
        // can take out sender id and receiver id later -- not needed cuz specifed in nodes already
        let messageDictionary = ["Sender ID": currUserID!, "Sender Name": currUser.name!, "Sender Image": currMessage.senderImage!, "Receiver ID": currMessage.receiverID!, "Receiver Name": currMessage.receiverName!, "Message Body": inputTextField.text!, "Time": sentTime] as [String : Any]
        
        // set value in current user's node
        messagesDB.child(currUserID!).child(currMessage.receiverID!).childByAutoId().updateChildValues(messageDictionary) { (error, ref) in // was setValue
            if error != nil {
                print(error!)
                return
            }
            else {
                print("Message saved successfully in current user's node")
            }
        }
        
        // set value in receiver's node
        messagesDB.child(currMessage.receiverID!).child(currUserID!).childByAutoId().updateChildValues(messageDictionary) { (error, ref) in // was setValue
            if error != nil {
                print(error!)
                return
            }
            else {
                print("Message saved successfully in receiver's node")
            }
            
        }

    }
    
    //MARK: Segue to correct tab
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTabVC" {
            if let tabVC = segue.destination as? UITabBarController{
                tabVC.selectedIndex = 3
            }
        }
    }
    
    //MARK: Back button segue
    @IBAction func backPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "goToTabVC", sender: self)
    }
    
    // when the enter key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // disable send and text field
        inputTextField.isEnabled = false
        sendButton.isEnabled = false

        getTime()
        
        handleSend(sentTime: sentTime)
        
        self.inputTextField.isEnabled = true
        self.sendButton.isEnabled = true
        self.inputTextField.text = ""
        
        return true
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
