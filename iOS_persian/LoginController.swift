//
//  LoginController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-02-27.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginController: UIViewController, FBSDKLoginButtonDelegate {

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
    
    let fbLoginButton = FBSDKLoginButton()
    
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
        do {
            try FIRAuth.auth()?.signOut()
        } catch { return }
        view.backgroundColor = .white
        setupViews()
        trackerEmailTextField.isHidden = true
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email", "public_profile"]
    }

    func setupViews() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(fbLoginButton)
        fbLoginButton.frame = CGRect(x: 16, y: 250, width: view.frame.width - 32, height: 50)
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
                if user.trackerId == "Company Owner" {
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
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
            return
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    //fb delegates
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print(error)
            return
        }
        fbGraphRequestThenAuthenticateAndStore()
        print("Successfully logged in with facebook!!!!!")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("Did log out of facebook!!!!")
    }
    
    func fbGraphRequestThenAuthenticateAndStore() {
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start { (connection, result, error) in
            if error != nil {
                print(error ?? "unknown error")
                return
            }
            let dictionary = result as? [String: AnyObject]
            let newUser = User()
            newUser.email = dictionary?["email"] as? String
            newUser.name = dictionary?["name"] as? String
            newUser.fbId = dictionary?["id"] as? String
            
            let accessToken = FBSDKAccessToken.current()
            guard let accessTokenString = accessToken?.tokenString else {return}
            let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessTokenString)
            FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
                if error != nil {
                    print("Could not log into Firebase", error ?? "unknown error")
                    return
                }
                print("Successfully logged into Firebase", user ?? "unknown user")
                self.checkIfUserExistInDBAndPushToRootOrRoleControllers(user: newUser)
            })
        }
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
}

