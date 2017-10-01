//
//  EditProfileViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/9/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // personal info outlets
    @IBOutlet var profileImage: UIImageView!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var ageTextField: UITextField!
    @IBOutlet var maleButton: UIButton!
    @IBOutlet var femaleButton: UIButton!
    @IBOutlet var bioTextField: UITextView!
    
    // dank preferences outlets
    @IBOutlet var sativa: UIButton!
    @IBOutlet var indica: UIButton!
    @IBOutlet var hybridSativa: UIButton!
    @IBOutlet var hybridIndica: UIButton!
    
    @IBOutlet var strain1TextField: UITextField!
    @IBOutlet var strain2TextField: UITextField!
    @IBOutlet var strain3TextField: UITextField!
    
    @IBOutlet var flower: UIButton!
    @IBOutlet var concentrate: UIButton!
    @IBOutlet var edible: UIButton!
    
    var currUser = User()
    
    var databaseRef: FIRDatabaseReference!
    
    //var genderSelected = ["", ""]
    //var genderDict = ["male", "female"]
    
    var typeSelected = ["", "", "", ""]
    var typeDict = ["Sativa", "Indica", "Hybrid-Sativa", "Hybrid-Indica"]
    
    var prefSelected = ["", "", ""]
    var prefDict = ["Flower", "Concentrate", "Edible"]
    
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        databaseRef = FIRDatabase.database().reference()
        
        styleButtons()
        
        profileImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selectProfileImage)))
        profileImage.isUserInteractionEnabled = true
        
        // get user info into page
        getUserPersonalInfo()
        
        //getDankPreferences()
        
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
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImagePicer: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImagePicer = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
            selectedImagePicer = originalImage
        }
        if let selectedImage = selectedImagePicer {
            profileImage.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }

    // fill out name, age, and picture
    func getUserPersonalInfo() {
        FIRDatabase.database().reference().child("Users").child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
            
            if let dictionary = snapshot.value as? [String: AnyObject] {
                self.currUser.name = dictionary["Name"] as! String?
                self.currUser.gender = dictionary["Gender"] as! String?
                self.currUser.age = dictionary["Age"] as! String?
                self.currUser.profileImageURL = dictionary["ProfileImageURL"] as! String?
                
                // fill user info in page
                self.nameTextField.text = self.currUser.name
                if self.currUser.age != nil {
                    self.ageTextField.text = self.currUser.age!
                }
                
                if self.currUser.gender != "" {
                    if self.currUser.gender == "male" {
                        self.maleButton.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else {
                        self.femaleButton.layer.backgroundColor = UIColor.purple.cgColor
                    }
                }
                
                self.profileImage.sd_setImage(with: URL(string: self.currUser.profileImageURL!), completed: nil)
                
                self.currUser.bio = dictionary["Bio"] as! String?
                self.bioTextField.text = self.currUser.bio
                
                
                self.currUser.preference = dictionary["Preference"] as! [String?]
                self.currUser.strains = (dictionary["Top Strains"] as! [String]?)!
                self.currUser.type = (dictionary["Type"] as! [String]?)!
                
                // fill info in page
                for type in self.currUser.type {
                    if type == "Sativa" {
                        self.sativa.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else if type == "Indica" {
                        self.indica.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else if type == "Hybrid-Sativa" {
                        self.hybridSativa.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else if type == "Hybrid-Indica" {
                        self.hybridIndica.layer.backgroundColor = UIColor.purple.cgColor
                    }
                }
                
                for (index, strain) in (self.currUser.strains.enumerated()) {
                    if index == 0 {
                        self.strain1TextField.text = strain
                    }
                    else if index == 1 {
                        self.strain2TextField.text = strain
                    }
                    else if index == 2 {
                        self.strain3TextField.text = strain
                    }
                }
                
                for pref in self.currUser.preference {
                    if pref == "Flower" {
                        self.flower.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else if pref == "Concentrate" {
                        self.concentrate.layer.backgroundColor = UIColor.purple.cgColor
                    }
                    else if pref == "Edible" {
                        self.edible.layer.backgroundColor = UIColor.purple.cgColor
                    }
                }
                
                
                
            }
            
        }, withCancel: nil)
    }
 
    
    @IBAction func genderSelected(_ sender: UIButton) {
        // change color back
        if sender.layer.backgroundColor == UIColor.purple.cgColor {
            sender.layer.backgroundColor = UIColor.clear.cgColor
            
        }
        // when selected
        else {
            sender.layer.backgroundColor = UIColor.purple.cgColor
        }
    }
    
    
    @IBAction func typeSelected(_ sender: UIButton) {
        // change color back
        if sender.layer.backgroundColor == UIColor.purple.cgColor {
            sender.layer.backgroundColor = UIColor.clear.cgColor
            //print("Removed: " + typeSelected[sender.tag])
            currUser.type[sender.tag] = ""
            //print(currUser.type)
            
        }
            // when selected
        else {
            sender.layer.backgroundColor = UIColor.purple.cgColor
            currUser.type[sender.tag] = typeDict[sender.tag]
            //print("Added: " + typeSelected[sender.tag])
            
            //print(currUser.type)
        }
    }
    
    
    @IBAction func preferenceSelected(_ sender: UIButton) {
        // change color back
        if sender.layer.backgroundColor == UIColor.purple.cgColor {
            sender.layer.backgroundColor = UIColor.clear.cgColor
            //print("Removed: " + prefSelected[sender.tag])
            currUser.preference[sender.tag] = ""
            //print(currUser.preference)
            
        }
            // when selected
        else {
            sender.layer.backgroundColor = UIColor.purple.cgColor
            currUser.preference[sender.tag] = prefDict[sender.tag]
            //print("Added: " + prefSelected[sender.tag])
            //print(currUser.preference)
        }
    }
    
    
    // save info in Firebase
    @IBAction func savedPressed(_ sender: UIBarButtonItem) {
        
        SVProgressHUD.show()
        
        let userID = FIRAuth.auth()?.currentUser?.uid
        let usersDB = self.databaseRef.child("Users").child(userID!)
        
        usersDB.child("Name").setValue(nameTextField.text)
        usersDB.child("Age").setValue(ageTextField.text)
        
        let gender: String
        if maleButton.layer.backgroundColor == UIColor.purple.cgColor {
            gender = "male"
        }
        else {
            gender = "female"
        }
        usersDB.child("Gender").setValue(gender)
        
        
        // gives us a unique string
        let imageName = NSUUID().uuidString
        
        // setup storage
        let storageRef = FIRStorage.storage().reference().child("\(imageName).png")
        
        // add image to storage
        if let uploadData = UIImagePNGRepresentation(self.profileImage.image!) {
            
            storageRef.put(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                    usersDB.child("ProfileImageURL").setValue(profileImageUrl)
                    SVProgressHUD.dismiss()
                    self.performSegue(withIdentifier: "goToTabVC", sender: self)
                }
                
            })
        }

        
        usersDB.child("Bio").setValue(bioTextField.text)
        
        /*while (currUser.type.contains(""))! {
            let index = currUser.type.index(of: "")
            currUser.type?.remove(at: index!)
        }*/
        
        usersDB.child("Type").setValue(currUser.type)
        
        let strains = ["\(self.strain1TextField.text!)", "\(self.strain2TextField.text!)", "\(self.strain3TextField.text!)"]
        currUser.strains = strains
        usersDB.child("Top Strains").setValue(currUser.strains)
     
        /*while (currUser.preference.contains(""))! {
            let index = currUser.preference.index(of: "")
            currUser.preference?.remove(at: index!)
        }*/
        usersDB.child("Preference").setValue(currUser.preference)
        
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "goToTabVC", sender: self)
    }
    
    
    
    func styleButtons() {
        // style buttons
        maleButton.layer.backgroundColor = UIColor.clear.cgColor
        maleButton.layer.borderColor = UIColor.black.cgColor
        maleButton.layer.borderWidth = 1
        maleButton.layer.cornerRadius = 5
        
        femaleButton.layer.backgroundColor = UIColor.clear.cgColor
        femaleButton.layer.borderColor = UIColor.black.cgColor
        femaleButton.layer.borderWidth = 1
        femaleButton.layer.cornerRadius = 5
        
        sativa.layer.backgroundColor = UIColor.clear.cgColor
        sativa.layer.borderColor = UIColor.black.cgColor
        sativa.layer.borderWidth = 1
        sativa.layer.cornerRadius = 5
        
        indica.layer.backgroundColor = UIColor.clear.cgColor
        indica.layer.borderColor = UIColor.black.cgColor
        indica.layer.borderWidth = 1
        indica.layer.cornerRadius = 5
        
        hybridSativa.layer.backgroundColor = UIColor.clear.cgColor
        hybridSativa.layer.borderColor = UIColor.black.cgColor
        hybridSativa.layer.borderWidth = 1
        hybridSativa.layer.cornerRadius = 5
        
        hybridIndica.layer.backgroundColor = UIColor.clear.cgColor
        hybridIndica.layer.borderColor = UIColor.black.cgColor
        hybridIndica.layer.borderWidth = 1
        hybridIndica.layer.cornerRadius = 5
        
        flower.layer.backgroundColor = UIColor.clear.cgColor
        flower.layer.borderColor = UIColor.black.cgColor
        flower.layer.borderWidth = 1
        flower.layer.cornerRadius = 5
        
        concentrate.layer.backgroundColor = UIColor.clear.cgColor
        concentrate.layer.borderColor = UIColor.black.cgColor
        concentrate.layer.borderWidth = 1
        concentrate.layer.cornerRadius = 5
        
        edible.layer.backgroundColor = UIColor.clear.cgColor
        edible.layer.borderColor = UIColor.black.cgColor
        edible.layer.borderWidth = 1
        edible.layer.cornerRadius = 5

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
