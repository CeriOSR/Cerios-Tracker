//
//  RolePickerController.swift
//  CeriosDrivr
//
//  Created by Rey Cerio on 2017-04-01.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class RolePickerController: UIViewController {

    var user = User()  {
        didSet{
            navigationItem.title = user.name
        }
    }
    
    lazy var driverOrDispatcherSegCon: UISegmentedControl = {
        let segCon = UISegmentedControl(items: ["Dispatcher", "Driver"])
        segCon.selectedSegmentIndex = 0
        //segCon.addTarget(self, action: #selector(hideTrackerEmailTextField), for: .valueChanged)
        return segCon
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Proceed", style: .plain, target: self, action: #selector(pushDriverOrDispatcher))
        setupViews()
    }
    
    func setupViews() {
        view.addSubview(driverOrDispatcherSegCon)
        
        view.addConstraintsWithVisualFormat(format: "H:|-10-[v0]-10-|", views: driverOrDispatcherSegCon)
        view.addConstraintsWithVisualFormat(format: "V:|-250-[v0(40)]", views: driverOrDispatcherSegCon)
        
    }
    
    func enterIntoDBIfNotExist(user: User, trackerId: String) {
        guard let email = user.email, let name = user.name, let fbId = user.fbId else {return}
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        let values = ["userId": uid, "name": name, "email": email, "fbId": fbId, "trackerId": trackerId]
        let databaseRef = FIRDatabase.database().reference().child("users").child(uid)
        databaseRef.updateChildValues(values, withCompletionBlock: { (error, reference) in
            if error != nil {
                print(error ?? "Something went wrong with the Database input...")
                return
            }
            if trackerId == "Pending dispatcher acceptance" {
                let fanRef = FIRDatabase.database().reference().child("pending_drivers")//.child(email)
//                let fanValues = ["driverId": uid, "fbId": values["fbId"]]
//                fanRef.updateChildValues(fanValues as! [String: String])
                fanRef.updateChildValues([uid: email])
            } else {
                
            }
        })
    }
    
    func pushDriverOrDispatcher() {
        if self.driverOrDispatcherSegCon.selectedSegmentIndex == 0 {
            enterIntoDBIfNotExist(user: user, trackerId: "Dispatcher")
            let layout = UICollectionViewFlowLayout()
            let trackerController = TrackerController(collectionViewLayout: layout)
            let navController1 = UINavigationController(rootViewController: trackerController)
            self.present(navController1, animated: true, completion: nil)
        } else {
            enterIntoDBIfNotExist(user: user, trackerId: "Pending dispatcher acceptance")
            let driverController = DriverController()
            driverController.trackerId = "Pending dispatcher acceptance"
            let navController2 = UINavigationController(rootViewController: driverController)
            self.present(navController2, animated: true, completion: nil)
        }
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
}
