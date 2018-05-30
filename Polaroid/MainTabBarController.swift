//
//  MainTabBarController.swift
//  Polaroid
//
//  Created by Kang Nam on 5/10/18.
//  Copyright © 2018 Kang Nam. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.index(of: viewController)
        if index == 2 {
            let layout = UICollectionViewFlowLayout()
            let photoSelectorController = PhotoSelectorController(collectionViewLayout: layout)
            let photoSelectorNavController = UINavigationController(rootViewController: photoSelectorController)
            present(photoSelectorNavController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                let loginController = LoginController()
                let navController = UINavigationController(rootViewController: loginController)
                self.present(navController, animated: true, completion: nil)
            }
            return
        }
        
        setupViewControllers()
    }
    
    func setupViewControllers() {
        
        let homeNavController = templateNavController(unselectedImage: (UIImage(named: "home_unselected")?.withRenderingMode(.alwaysOriginal))!, selectedImage: (UIImage(named: "home_selected")?.withRenderingMode(.alwaysOriginal))!, rootViewController: HomeController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let searchNavController = templateNavController(unselectedImage: (UIImage(named: "search_unselected")?.withRenderingMode(.alwaysOriginal))!, selectedImage: (UIImage(named: "search_selected")?.withRenderingMode(.alwaysOriginal))!, rootViewController: UserSearchController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        let plusNavController = templateNavController(unselectedImage: (UIImage(named: "plus_unselected")?.withRenderingMode(.alwaysOriginal))!, selectedImage: (UIImage(named: "plus_photo")?.withRenderingMode(.alwaysOriginal))!, rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
//        let likeNavController = templateNavController(unselectedImage: (UIImage(named: "like_unselected")?.withRenderingMode(.alwaysOriginal))!, selectedImage: (UIImage(named: "like_selected")?.withRenderingMode(.alwaysOriginal))!, rootViewController: UIViewController())
        
        let userProfileNavController = templateNavController(unselectedImage: (UIImage(named: "profile_unselected")?.withRenderingMode(.alwaysOriginal))!, selectedImage: (UIImage(named: "profile_selected")?.withRenderingMode(.alwaysOriginal))!, rootViewController: UserProfileController(collectionViewLayout: UICollectionViewFlowLayout()))
        
//        viewControllers = [homeNavController, searchNavController, plusNavController, likeNavController, userProfileNavController]
        viewControllers = [homeNavController, searchNavController, plusNavController, userProfileNavController]
        
        guard let items = tabBar.items else { return }
        for item in items {
            item.imageInsets = UIEdgeInsetsMake(4, 0, -4, 0)
        }
    }
    
    fileprivate func templateNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController = UIViewController()) -> UINavigationController {
        let viewController = rootViewController
        let navController = UINavigationController(rootViewController: viewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        return navController
    }
    
}
