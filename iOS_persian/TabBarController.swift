//
//  TabBarController.swift
//  iOS_persian
//
//  Created by Rey Cerio on 2017-05-24.
//  Copyright © 2017 CeriOS. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
        override func viewDidLoad() {
        super.viewDidLoad()
                
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

}
