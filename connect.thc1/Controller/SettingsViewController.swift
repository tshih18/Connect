//
//  SettingsViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/7/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class SettingsViewController: UIViewController {
  
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        do {
            try FIRAuth.auth()?.signOut()
            let manager = FBSDKLoginManager()
            manager.logOut()
            print("Signed out frome email account successfully")
            self.performSegue(withIdentifier: "goToLaunch", sender: self)
        }
        catch let logoutError {
            print(logoutError)
        }
        
        
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

