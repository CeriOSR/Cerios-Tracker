//
//  TrackerController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-04-05.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TrackerController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var rootViewController = RootViewController()
    var user: User? {
        didSet{
            navigationItem.title = user?.name
            print("tracker", user?.name)
        }
    }
    var timer = Timer()
    var drivers = [User]()
    let cellId = "cellId"
    var driverIsActiveId = String()
    var driverId = String()
    var driversId = [String]()
    let uid = FIRAuth.auth()?.currentUser?.uid
    var isPinged = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView?.backgroundColor = .white
        collectionView?.register(DispatcherCell.self, forCellWithReuseIdentifier: cellId)
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(handleMessageView))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchDrivers()
    }
        
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return drivers.count
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DispatcherCell
        let users = drivers[indexPath.item]
        cell.nameLabel.text = users.name
        
        let index = driversId[indexPath.item]
        
        FIRDatabase.database().reference().child("CER_driver_online").child(uid!).child(index).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            if dictionary == nil {
                cell.activeLabel.text = ""
            } else {
                cell.activeLabel.text = "Ping Active"
                cell.activeLabel.textColor = UIColor.green
            }
            //because the child is deleted this makes the activeLabel flicker!!! happy coincedence!
            self.timer.invalidate()
            self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.attemptReloadTable), userInfo: nil, repeats: false)
        }, withCancel: nil)
        return cell
    }
    
    func attemptReloadTable() {
        DispatchQueue.main.async(execute: {
            self.collectionView?.reloadData()
        })
    }
    
    func activePing(index: String) {
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        FIRDatabase.database().reference().child("CER_user_location").child(uid!).child(driversId[indexPath.item]).observeSingleEvent(of: .value, with: { (snapshot) in
            let dictionary = snapshot.value as? [String: AnyObject]
            
            if dictionary == nil {
                self.createAlert(title: "Driver Not Pinged", message: "Please ask the driver to ping location.")
                return
            } else {
                let driverLocationController = DriverLocationController()
                driverLocationController.driverId = self.driversId[indexPath.item]   //array of drivers id
                driverLocationController.driver = self.drivers[indexPath.item]
                let navDriverLoc = UINavigationController(rootViewController: driverLocationController)
                self.present(navDriverLoc, animated: true, completion: nil)
            }
        }, withCancel: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 75)
    }
    
    func createAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            //self.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
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
    
    func handleRegisterButton() {
        let registerController = RegisterController()
        let navController = UINavigationController(rootViewController: registerController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleMessageView() {
        let layout = UICollectionViewFlowLayout()
        print("handleMessage function", user?.email)

        guard let currentUser = user else {return}
        let messageViewController = MessageViewController(collectionViewLayout: layout)
        messageViewController.currentUser = currentUser
        messageViewController.trackerController = self
        let messageNavController = UINavigationController(rootViewController: messageViewController)
        self.present(messageNavController, animated: true, completion: nil)
        
//        let layout = UICollectionViewFlowLayout()
//        let controller = MessageViewController(collectionViewLayout: layout)
//        controller.user = user
//        controller.trackerController = self
//        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func fetchDrivers() {
        guard let uid = FIRAuth.auth()?.currentUser?.uid else {return}
        drivers = []
        let databaseRef = FIRDatabase.database().reference().child("company_drivers").child("\(uid)")
        databaseRef.observe(.childAdded, with: { (snapshot) in
            
            self.driverId = snapshot.key
            self.driversId.append(snapshot.key)
            let userRef = FIRDatabase.database().reference().child("users").child(self.driverId)
            userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                
                guard let dictionary = snapshot.value as? [String: AnyObject] else {return}
                let users = User()
                users.name = dictionary["name"] as? String
                users.email = dictionary["email"] as? String
                users.userId = dictionary["userId"] as? String
                
                self.drivers.append(users)
                DispatchQueue.main.async(execute: {
                    self.collectionView?.reloadData()
                })
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
}

