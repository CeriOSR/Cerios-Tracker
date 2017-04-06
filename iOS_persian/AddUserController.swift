//
//  AddUserController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-03-15.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class AddUserController: UIViewController {
    
    let uid = FIRAuth.auth()?.currentUser?.uid
    var tracker: User? {
        didSet{
            navigationItem.title = tracker?.name
        }
    }

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "email"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        return tf
    }()
    
    let trackerIdTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "tracker ID"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        tf.isUserInteractionEnabled = false
        tf.textColor = .gray
        return tf
    }()


    lazy var addUserButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add User", for: .normal)
        button.addTarget(self, action: #selector(handleAddUser), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        trackerIdTextField.text = uid
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        setupViews()

    }
    
    func setupViews() {
        view.addSubview(emailTextField)
        view.addSubview(trackerIdTextField)
        view.addSubview(addUserButton)
        
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: emailTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: trackerIdTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-130-[v0(100)]", views: addUserButton)

        view.addConstraintsWithVisualFormat(format: "V:|-100-[v0(40)]-10-[v1(40)]-50-[v2(40)]", views: emailTextField, trackerIdTextField, addUserButton)


    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handleAddUser() {
        
        //find the user in pending node
        
        //add them under their tracker id in company_driver node and update the trackerId in the usernode
        
        //delete them from the pending_user node
        
        
        guard let email = emailTextField.text else {
            createAlert(title: "Enter a valid email", message: "Please enter a valid email.")
            return
        }
        let pendingRef = FIRDatabase.database().reference().child("pending_users")
        //fix this here so it only adds the driver with the corresponding email....
        pendingRef.observe(.childAdded, with: { (snapshot) in
            let pendingDictionary = snapshot.value as? [String: AnyObject]
            let pendingUser = User()
            pendingUser.email = pendingDictionary?["email"] as? String
            pendingUser.fbId = pendingDictionary?["fbId"] as? String
            pendingUser.userId = snapshot.key
            
            if email == pendingUser.email {
                guard let addUserId = pendingUser.userId else {return}
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
                let userRef = FIRDatabase.database().reference().child("user").child(addUserId)
                userRef.updateChildValues(["trackerId": uid])
                userRef.updateChildValues(["trackerId": uid], withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(error ?? "unknown error!")
                        return
                    }
                    let fanRef = FIRDatabase.database().reference().child("company_drivers").child("\(uid)")
                    fanRef.updateChildValues([addUserId:1])
                    pendingRef.removeValue()
                    self.handleBack()
                })
            } else {
                self.createAlert(title: "Driver Does Not Exist.", message: "Driver mail not found.")
            }
        }, withCancel: nil)
    }
    
    func handleBack() {
        let layout = UICollectionViewFlowLayout()
        let trackerController = TrackerController(collectionViewLayout: layout)
        let navController1 = UINavigationController(rootViewController: trackerController)
        self.present(navController1, animated: true, completion: nil)
    }

}
