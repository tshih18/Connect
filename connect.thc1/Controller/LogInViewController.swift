//
//  LogInViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/4/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LogInViewController: UIViewController {

    @IBOutlet var errorMessageField: UILabel!
    @IBOutlet var emailTextLabel: UITextField!
    @IBOutlet var passwordTextLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logInPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        FIRAuth.auth()?.signIn(withEmail: emailTextLabel.text!, password: passwordTextLabel.text!, completion: { (user, error) in
            if error != nil {
                print(error!)
                self.errorMessageField.text = "Invalid email or password"
                print(error.debugDescription)
                
            }
            else {
                print("Login Successful")
                self.performSegue(withIdentifier: "goToTabVC", sender: self)
                
                //let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                //let tabViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "tabViewController")
                //self.present(tabViewController, animated: true, completion: nil)
                
            }
            SVProgressHUD.dismiss()
            
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
