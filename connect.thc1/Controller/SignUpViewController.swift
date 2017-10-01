//
//  SignUpViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/4/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var errorMessageField: UILabel!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var passwordConfirmationTextField: UITextField!
    
    var databaseRef: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // setup reference to Firebase
        databaseRef = FIRDatabase.database().reference()
        
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
        profileImageView.isUserInteractionEnabled = true
    }
    
    // bring up image picker
    func selectProfileImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    // when clicked cancel on image picker
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        print("Canceled Picker")
        
    }
    
    // when an image is picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagePicer: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagePicer = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImagePicer = originalImage
        }
        if let selectedImage = selectedImagePicer {
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    @IBAction func signUpPressed(_ sender: Any) {
        SVProgressHUD.show()
        
        // temporarily disable text field and send button when sending to Firebase
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        passwordConfirmationTextField.endEditing(true)
        emailTextField.isEnabled = false
        passwordTextField.isEnabled = false
        passwordConfirmationTextField.isEnabled = false
        
        if (passwordTextField.text == passwordConfirmationTextField.text) {
            FIRAuth.auth()?.createUser(withEmail: emailTextField.text!, password: passwordTextField.text!, completion: { (user, error) in
                if error != nil {
                    print(error!)
                    self.errorMessageField.text = "Invalid email or password"
                    self.emailTextField.isEnabled = true
                    self.passwordTextField.isEnabled = true
                    self.passwordConfirmationTextField.isEnabled = true
                    SVProgressHUD.dismiss()
                    return
                }
                else {
                    print("Authenticaion Successful")
                    
                    // get user id
                    guard let userID = user?.uid else { return }
                
                    // gives us a unique string
                    let imageName = NSUUID().uuidString
                
                    // setup storage
                    let storageRef = FIRStorage.storage().reference().child("\(imageName).jpg")
        
                    // add image to storage
                    // compress image to smaller size
                    if let uploadData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1) {
                    
                    //if let uploadData = UIImagePNGRepresentation(self.profileImageView.image!) {

                        storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                            if error != nil {
                                print(error!)
                                return
                            }
                            if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
 
                                let usersDict = ["Name": self.nameTextField.text!, "Email": self.emailTextField.text!,
                                                 "Uid": userID, "Gender": "", "Age": "", "Interest": "", "ProfileImageURL": profileImageUrl, "Bio": "", "Preference": "", "Top Strains": "", "Type": "", "Swiped Right": "", "Liked": "", "Matched": ""]
                                
                                // add to database
                                self.registerUserIntoDatabase(userID: userID, usersDict: usersDict)
                                self.performSegue(withIdentifier: "goToHome", sender: self)
                                SVProgressHUD.dismiss()
                            }
                            
                        })
                    }
                }
            })
        }
        else {
            print("Passwords need to match")
            self.errorMessageField.text = "Passwords need to match"
        }
    }
    
    private func registerUserIntoDatabase(userID: String, usersDict: [String: String]) {
        // set reference to Firebase in "Users" node
        let usersDB = self.databaseRef.child("Users")
        
        // save info
        usersDB.child(userID).setValue(usersDict) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            print("User's name, email, uid, and picture saved successfully")
            self.emailTextField.isEnabled = true
            self.passwordTextField.isEnabled = true
            self.passwordConfirmationTextField.isEnabled = true
 
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
