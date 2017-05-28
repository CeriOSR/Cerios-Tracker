//
//  TabBarController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-05-24.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class TabBarController: UITabBarController {
    
    var currentUser: User? {
        didSet{
            navigationItem.title = currentUser?.name
        }
    }
    var rootViewController = RootViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(handleMessageView))
        
        let layoutTracker = UICollectionViewFlowLayout()
        let trackerController = TrackerController(collectionViewLayout: layoutTracker)
        let trackerNavController = UINavigationController(rootViewController: trackerController)
        trackerNavController.tabBarItem.image = UIImage(named: "groups")
        trackerNavController.tabBarItem.title = "Drivers"
        
        let addUserController = AddUserController()
        let addUserNavController = UINavigationController(rootViewController: addUserController)
        addUserNavController.tabBarItem.image = UIImage(named: "people")
        addUserNavController.tabBarItem.title = "Add Driver"
        
        viewControllers = [trackerNavController, addUserNavController]
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
    
    private func handleRegisterButton() {
        let registerController = RegisterController()
        let navController = UINavigationController(rootViewController: registerController)
        present(navController, animated: true, completion: nil)
    }
    
    func handleMessageView() {
        let layout = UICollectionViewFlowLayout()
        let messageViewController = MessageViewController(collectionViewLayout: layout)
        messageViewController.currentUser = currentUser
        let messageNavController = UINavigationController(rootViewController: messageViewController)
        self.present(messageNavController, animated: true, completion: nil)
    }


}
