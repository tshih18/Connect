//
//  ProfileViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/7/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    @IBOutlet var profilePicImage: UIImageView!
    @IBOutlet var nameTextLabel: UILabel!
    @IBOutlet var prefTextFieldLabel: UILabel!
    @IBOutlet var bioTextField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserProfile()
    }
    
    func loadUserProfile() {
        
        // set user's name and profile picture
        let uid = FIRAuth.auth()?.currentUser?.uid
        FIRDatabase.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                currUser.name = dictionary["Name"] as! String?
                currUser.gender = dictionary["Gender"] as! String?
                currUser.age = dictionary["Age"] as! String?
                currUser.profileImageURL = dictionary["ProfileImageURL"] as! String?

                self.nameTextLabel.text = currUser.name!
                
                if currUser.age != "" {
                    self.nameTextLabel.text = self.nameTextLabel.text! + ", \(currUser.age!)"
                }
                
                if currUser.gender != "" {
                    self.nameTextLabel.text = self.nameTextLabel.text! + ", \(currUser.gender!)"
                }
                
                
                self.profilePicImage.sd_setImage(with: URL(string: currUser.profileImageURL!), completed: nil)
                
                currUser.bio = dictionary["Bio"] as! String?
                self.bioTextField.text = currUser.bio
                
                currUser.preference = (dictionary["Preference"] as! [String]?)!
                currUser.strains = (dictionary["Top Strains"] as! [String]?)!
                currUser.type = (dictionary["Type"] as! [String]?)!
                
                var preferences = ""
                var strains = ""
                var types = ""
                for pref in currUser.preference {
                    preferences += pref! + "\n                    "
                }
                for strain in currUser.strains {
                    strains += strain! + "\n                     "
                }
                for type in currUser.type {
                    types += type! + "\n          "
                }
                
                self.prefTextFieldLabel.text = "Preference: \(preferences) \nTop Strains: \(strains) \nType: \(types)"
            }
            
        }, withCancel: nil)

    }
    
        override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
