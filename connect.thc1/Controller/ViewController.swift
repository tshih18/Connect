//
//  ViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/3/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
import SVProgressHUD

class ViewController: UIViewController, FBSDKLoginButtonDelegate, GIDSignInUIDelegate {

    @IBOutlet var fbLoginButton: UIButton!
    @IBOutlet var googleLoginButton: UIButton!

    var ref: FIRDatabaseReference!
    let userID = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        ref = FIRDatabase.database().reference()
        
        
        // facebook login
        setupFacebookButtons()
        
        // google login
        setupGoogleButtons()
    }
    
    
    // native facebook button
    fileprivate func setupFacebookButtons() {
        
        /*
        let loginButton = FBSDKLoginButton()
        view.addSubview(loginButton)
        loginButton.frame = CGRect(x: 40, y: 300, width: view.frame.width-100, height: 50)
        loginButton.delegate = self
        loginButton.readPermissions = ["email", "public_profile"]
        */
 
 
        // setup custom fb login button
        fbLoginButton.addTarget(self, action: #selector(handleCustomFBLogin), for: .touchUpInside)
    }
    
    // custom facebook button
    func handleCustomFBLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile", "user_location"], from: self) { (result, error) in
            if error != nil {
                print("Custom FB Login Failed")
                return
            }
            
            print("Successfully logged in with facebook using custom button")
            //print(result?.token.tokenString)
            self.fbLogin()
        }
    }
    
    // native google button
    fileprivate func setupGoogleButtons() {
        /*
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 40, y: 300 + 60, width: view.frame.width-100, height: 50)
        view.addSubview(googleButton)
        */
        
        GIDSignIn.sharedInstance().uiDelegate = self
 
        // adding custom google button
        googleLoginButton.addTarget(self, action: #selector(handleCustomGoogleLogin), for: .touchUpInside)
        
    }
    
    // custom google button
    func handleCustomGoogleLogin() {
        GIDSignIn.sharedInstance().signIn()
        self.performSegue(withIdentifier: "goToHome", sender: self)
    }
    
    

    // native facebook logout button
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Logged out of facebook")
    }
    
    // native facebook login button
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }

        print("Successfully logged in with facebook using native button")
        fbLogin()
    }

    
    func fbLogin() {
        SVProgressHUD.show()
        // link facebook credentials with firebase
        let accessToken = FBSDKAccessToken.current()
        
        guard let accessTokenString = accessToken?.tokenString else { return }
        
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something went wrong with our Facebook user")
                return
            }
            
            print("Successfully logged into Firebase with Facebook")
            
            let userID = FIRAuth.auth()?.currentUser?.uid
   
            var notFound = true
            
            // check for new user
            self.ref.child("Users").observe(FIRDataEventType.value, with: { (snapshot) in
                while(notFound) {
                    // if user is already in database go directly to profile and load info from database
                    if snapshot.hasChild(userID!) {
                        self.performSegue(withIdentifier: "goToTabVC", sender: self)
                        return
                    }
                    // else get info from facebook
                    else {
                        notFound = false
                        self.getLoginInfo()
                        self.performSegue(withIdentifier: "goToHome", sender: self)
                    }
                }
            })

            SVProgressHUD.dismiss()
        })
        
    }
    
    func getLoginInfo() {
        
        // if user is not in database
        
        
        let parameters = ["fields": "id, first_name, last_name, email, gender, cover, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "/me", parameters: parameters).start { (connection, result, error) in
    
            if error != nil {
                print("Failed to start graph result", error!)
                return
            }
            
            guard
                let result = result as? NSDictionary,
                // use Firebase ID not Facebook ID
                let newUserID = FIRAuth.auth()?.currentUser?.uid,
                let email = result["email"] as? String,
                let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let name = "\(firstName) \(lastName)" as? String,
                let gender = result["gender"] as? String,
                
                let picture = result["picture"] as? NSDictionary,
                let data = picture["data"] as? NSDictionary,
                let url = data["url"] as? String

            else {
                return
            }
            
            let fbUsersDict = ["Name": name, "Email": email, "Uid": newUserID, "Gender": gender, "Age": "", "Interest": "", "ProfileImageURL": url, "Bio": "", "Preference": "", "Top Strains": "", "Type": "", "Swiped Right": "", "Liked": "", "Matched": ""]
            // save facebook user to firebase
            self.registerFbUserIntoDatabase(newUserID: newUserID, fbUsersDict: fbUsersDict)
            
        }
    }

    // add new facebook user into database
    func registerFbUserIntoDatabase(newUserID: String, fbUsersDict: [String: String]) {
        let usersDB = self.ref.child("Users")
        let newUserID = FIRAuth.auth()?.currentUser?.uid
    
        usersDB.child(newUserID!).setValue(fbUsersDict) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            print("FB User's name, email, uid, gender, and picture saved successfully")
        }
    }
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

