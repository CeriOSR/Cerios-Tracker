//
//  RegisterController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-02-28.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class RegisterController: UIViewController {

    
    
    let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "name"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        return tf
    }()
    
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
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.isSecureTextEntry = true
        tf.autocorrectionType = .no
        tf.autocapitalizationType = .none
        tf.placeholder = "password"
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
        tf.isHidden = false
        return tf
    }()

    
    let trackerDriverSegCon: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Driver", "Tracker"])
        sc.selectedSegmentIndex = 0
        sc.addTarget(self, action: #selector(hideTrackerIdField), for: .valueChanged)
        return sc
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(handleRegister), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleBack))
        setupViews()
        
    }
    
    func setupViews() {
        view.addSubview(nameTextField)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(trackerDriverSegCon)
        view.addSubview(trackerIdTextField)
        view.addSubview(registerButton)

        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: nameTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: emailTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: passwordTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-20-[v0]-20-|", views: trackerDriverSegCon)
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: trackerIdTextField)
        view.addConstraintsWithVisualFormat(format: "H:|-130-[v0(100)]", views: registerButton)

        view.addConstraintsWithVisualFormat(format: "V:|-100-[v0(40)]-10-[v1(40)]-10-[v2(40)]-10-[v3(40)]-10-[v4(40)]-40-[v5(40)]", views: nameTextField, emailTextField, passwordTextField, trackerDriverSegCon, trackerIdTextField, registerButton)
        
    }
    
    func hideTrackerIdField() {
        if trackerDriverSegCon.selectedSegmentIndex == 0 {
            trackerIdTextField.isHidden = false
        } else if trackerDriverSegCon.selectedSegmentIndex == 1 {
            trackerIdTextField.isHidden = true
        }
    }
    
    func handleBack() {
        let layout = UICollectionViewFlowLayout()
        let trackerController = TrackerController(collectionViewLayout: layout)
        let navController1 = UINavigationController(rootViewController: trackerController)
        self.present(navController1, animated: true, completion: nil)
    }
    
    func handleRegister() {
        
        guard let name = nameTextField.text else {return}
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        var trackerId = String()
        
        if trackerDriverSegCon.selectedSegmentIndex == 0 {
            trackerId = self.trackerIdTextField.text!
        } else if trackerDriverSegCon.selectedSegmentIndex == 1 {
            trackerId = "Company Owner"
        }
        
        FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "something went wrong with the registration process")
                return
            }
            if self.trackerDriverSegCon.selectedSegmentIndex == 0 {
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
                let values = ["userId": uid, "name": name, "email": email, "password": password, "trackerId": trackerId ]
                let databaseRef = FIRDatabase.database().reference().child("users").child(uid)
                databaseRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(error ?? "Something went wrong with the Database input...")
                        return
                    }
                    let fanRef = FIRDatabase.database().reference().child("company_drivers").child("\(trackerId)")
                    fanRef.updateChildValues([uid:1])
                    self.handleBack()
                })
            } else if self.trackerDriverSegCon.selectedSegmentIndex == 1{
                
                guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
                let values = ["userId": uid, "name": name, "email": email, "password": password, "trackerId": trackerId ]
                let databaseRef = FIRDatabase.database().reference().child("users").child(uid)
                databaseRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
                    if error != nil {
                        print(error ?? "Something went wrong with the Database input...")
                        return
                    }
                    self.pushTrackerController()
                })
            }
        })
    }
    
    func pushTrackerController() {
        
        let layout = UICollectionViewFlowLayout()
        let trackerController = TrackerController(collectionViewLayout: layout)
        trackerController.fetchDrivers()
        let navTrackerController = UINavigationController(rootViewController: trackerController)
        self.present(navTrackerController, animated: true, completion: nil)
        
    }
    
    func pushDriverController(trackerId: String) {
        
        let driverController = DriverController()
        driverController.trackerId = trackerId
        let navDriverController = UINavigationController(rootViewController: driverController)
        self.present(navDriverController, animated: true, completion: nil)
        
    }
}



































