//
//  EmailPhoneLoginController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-05-27.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase

class EmailPhoneLoginController: UIViewController {

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
    
    lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        return button
    }()
    
    let orLabel: UILabel = {
        let label = UILabel()
        label.text = "Or"
        return label
    }()
    
    lazy var registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(handleRegisterButton), for: .touchUpInside)
        return button
    }()
    
    
    lazy var driverOrDispatcherSegCon: UISegmentedControl = {
        let segCon = UISegmentedControl(items: ["Dispatcher", "Driver"])
        segCon.selectedSegmentIndex = 0
        segCon.addTarget(self, action: #selector(hideTrackerEmailTextField), for: .valueChanged)
        return segCon
    }()
    
    let trackerEmailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "tracker email"
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 6.0
        tf.layer.masksToBounds = true
        tf.isHidden = false
        return tf
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    func hideTrackerEmailTextField() {
        if driverOrDispatcherSegCon.selectedSegmentIndex == 0 {
            trackerEmailTextField.isHidden = true
        } else {
            trackerEmailTextField.isHidden = false
        }
    }
    
    func handleRegisterButton() {
        let registerController = RegisterController()
        let navController = UINavigationController(rootViewController: registerController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleLogin() {
        guard let email = emailTextField.text else {return}
        guard let password = passwordTextField.text else {return}
        FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
            if error != nil {
                print(error ?? "Something went wrong in the sign in process.")
            }
            guard let uid = user?.uid else {return}
            FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                let dictionary = snapshot.value as? [String: AnyObject]
                let user = User()
                user.trackerId = dictionary?["trackerId"] as! String?
                if user.trackerId == "Dispatcher" {
                    let layout = UICollectionViewFlowLayout()
                    let trackerController = TrackerController(collectionViewLayout: layout)
                    let navController1 = UINavigationController(rootViewController: trackerController)
                    self.present(navController1, animated: true, completion: nil)
                } else {
                    let driverController = DriverController()
                    driverController.trackerId = user.trackerId!
                    let navController2 = UINavigationController(rootViewController: driverController)
                    self.present(navController2, animated: true, completion: nil)
                }
            }, withCancel: nil)
        })
    }
    
    func checkIfUserExistInDBAndPushToRootOrRoleControllers(user: User) {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let checkTrackerRef = FIRDatabase.database().reference().child("users").child(uid)
        checkTrackerRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            let trackerId = dictionary?["trackerId"] as? String
            print(trackerId ?? "tracker id does not exist")
            if trackerId == nil {
                let rolePickerController = RolePickerController()
                rolePickerController.user = user
                let navController = UINavigationController(rootViewController: rolePickerController)
                self.present(navController, animated: true, completion: nil)
            } else {
                let rootViewController = RootViewController()
                rootViewController.trackerId = trackerId!
                self.present(rootViewController, animated: true, completion: nil)
            }
        }, withCancel: nil)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }


}
