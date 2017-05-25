//
//  RootViewController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-04-01.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class RootViewController: UIViewController {

    var trackerId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        checkIfUserExist()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //handleLogout()
        checkIfUserExist()
    }

    func pushDriverOrDispatcher() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        FIRDatabase.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            let user = User()
            user.email = dictionary?["email"] as? String
            user.fbId = dictionary?["fbId"] as? String
            user.name = dictionary?["name"] as? String
            user.userId = uid
            user.trackerId = dictionary?["trackerId"] as? String
            
            print(user.trackerId!, user.name!)
            
            guard let trackerId = user.trackerId else {return}
            if trackerId == "Dispatcher" {
                let tabBarController = TabBarController()
//                let trackerController = TrackerController()
//                trackerController.user = user
//                trackerController.rootViewController = self
                
                
                tabBarController.currentUser = user
                tabBarController.rootViewController = self
                let tabBarNavController = UINavigationController(rootViewController: tabBarController)
                self.present(tabBarNavController, animated: true, completion: nil)
            } else {
                let driverController = DriverController()
                driverController.trackerId = trackerId
                let navController2 = UINavigationController(rootViewController: driverController)
                self.present(navController2, animated: true, completion: nil)
            }
        }, withCancel: nil)
    }
    
    func handleLogout() {
        do {
            try FIRAuth.auth()?.signOut()
        } catch let err {
            print(err)
            return
        }
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        let loginController = LoginController()
        present(loginController, animated: true, completion: nil)
    }
    
    func checkIfUserExist() {
        if FIRAuth.auth()?.currentUser?.uid == nil {
            handleLogout()
        } else {
            pushDriverOrDispatcher()
        }
    }


}
