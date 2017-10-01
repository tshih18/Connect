//
//  HomeViewController.swift
//  connect.thc1
//
//  Created by Theodore Shih on 9/5/17.
//  Copyright © 2017 Theodore Shih. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController {

    @IBOutlet var strain1TextField: UITextField!
    @IBOutlet var strain2TextField: UITextField!
    @IBOutlet var strain3TextField: UITextField!
    @IBOutlet var sativaButton: UIButton!
    @IBOutlet var indicaButton: UIButton!
    @IBOutlet var hybridSativaButton: UIButton!
    @IBOutlet var hybridIndicaButton: UIButton!
    @IBOutlet var flowerButton: UIButton!
    @IBOutlet var concentrateButton: UIButton!
    @IBOutlet var edibleButton: UIButton!
    
    var typeDict = ["Sativa", "Indica", "Hybrid-Sativa", "Hybrid-Indica"]
    var prefDict = ["Flower", "Concentrate", "Edible"]
    var typesSelected = ["", "", "", ""]
    var prefSelected = ["", "", ""]
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // setup reference to Firebase
        ref = FIRDatabase.database().reference()
        
        // add style to buttons
        styleButtons()
    }
    
    func styleButtons() {
        sativaButton.layer.borderWidth = 1
        sativaButton.layer.borderColor = UIColor.black.cgColor
        sativaButton.layer.cornerRadius = 5
        
        indicaButton.layer.borderWidth = 1
        indicaButton.layer.borderColor = UIColor.black.cgColor
        indicaButton.layer.cornerRadius = 5
        
        hybridSativaButton.layer.borderWidth = 1
        hybridSativaButton.layer.borderColor = UIColor.black.cgColor
        hybridSativaButton.layer.cornerRadius = 5
        
        hybridIndicaButton.layer.borderWidth = 1
        hybridIndicaButton.layer.borderColor = UIColor.black.cgColor
        hybridIndicaButton.layer.cornerRadius = 5
        
        flowerButton.layer.borderWidth = 1
        flowerButton.layer.borderColor = UIColor.black.cgColor
        flowerButton.layer.cornerRadius = 5
        concentrateButton.layer.borderWidth = 1
        concentrateButton.layer.borderColor = UIColor.black.cgColor
        concentrateButton.layer.cornerRadius = 5
        edibleButton.layer.borderWidth = 1
        edibleButton.layer.borderColor = UIColor.black.cgColor
        edibleButton.layer.cornerRadius = 5
    }


    
    @IBAction func typeSelected(_ sender: UIButton) {
        
        
        // change color back
        if sender.backgroundColor == .purple {
            sender.backgroundColor = .clear
            typesSelected[sender.tag] = ""
            //print("Removed: " + typeDict[sender.tag])
        }
        // when selected
        else {
            sender.backgroundColor = .purple
            typesSelected[sender.tag] = typeDict[sender.tag]
            //print("Added: " + typeDict[sender.tag])
            
        }
   
    }
  
    
    @IBAction func preferenceSelected(_ sender: UIButton) {
        
        // change color back
        if sender.backgroundColor == .purple {
            sender.backgroundColor = .clear
            prefSelected[sender.tag] = ""
            //print("Removed: " + prefDict[sender.tag])
        }
        // when selected
        else {
            sender.backgroundColor = .purple
            prefSelected[sender.tag] = prefDict[sender.tag]
            //print("Added: " + prefDict[sender.tag])
        }
        
    }
    

    
    @IBAction func submitPressed(_ sender: Any) {
        /* truncate data
        while typesSelected.contains("") {
            let index = typesSelected.index(of: "")
            typesSelected.remove(at: index!)
        }
        
        while prefSelected.contains("") {
            let index = prefSelected.index(of: "")
            prefSelected.remove(at: index!)
        }*/
        
        //print("Types selected: ", typesSelected)
        //print("Preference selected: ", prefSelected)
        
        // set reference to Firebase in "Users" node
        let usersDB = self.ref.child("Users")
        
        // get user id
        let userID = FIRAuth.auth()?.currentUser?.uid
        
        //print(userID!)
        /*let prefDict = ["Type": typesSelected,
                        "Top Strains": [strain1TextField.text, strain2TextField.text, strain3TextField.text],
                        "Preference": prefSelected] as [String : Any]
        */
        /* save info
        usersDB.child(userID!).setValue(prefDict) { (error, ref) in
            if error != nil {
                print(error ?? "")
            }
            else {
                print("Successfully saved info to database")
                self.performSegue(withIdentifier: "goToTabVC", sender: self)
            }
            
        }*/
        
        usersDB.child(userID!).child("Type").setValue(typesSelected)
        usersDB.child(userID!).child("Top Strains").setValue([strain1TextField.text, strain2TextField.text, strain3TextField.text])
        usersDB.child(userID!).child("Preference").setValue(prefSelected)
        performSegue(withIdentifier: "goToTabVC", sender: self)
        
        
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
