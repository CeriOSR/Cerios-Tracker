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
            
            guard let trackerId = dictionary?["trackerId"] as! String? else {return}
            if trackerId == "Dispatcher" {
                let layout = UICollectionViewFlowLayout()
                let trackerController = TrackerController(collectionViewLayout: layout)
                let navController1 = UINavigationController(rootViewController: trackerController)
                self.present(navController1, animated: true, completion: nil)
            } else {
                let driverController = DriverController()
                driverController.trackerId = trackerId
                let navController2 = UINavigationController(rootViewController: driverController)
                self.present(navController2, animated: true, completion: nil)
                //self.createAlert(title: "Not Authorized.", message: "Please log in as a dispatcher")
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
