//
//  MainViewController.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class MainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.setupViewControllers()
    }
 
    private func setupViewControllers() {
        let firstVC = UINavigationController(rootViewController: NewBooksViewController())
        firstVC.tabBarItem = UITabBarItem(title: "NEW", image: UIImage(systemName: "book"), tag: 0)
        
        let secondVC = UINavigationController(rootViewController: SearchBookViewController())
        secondVC.tabBarItem = UITabBarItem(title: "SEARCH", image: UIImage(systemName: "magnifyingglass"), tag: 1)
        
        self.setViewControllers([firstVC, secondVC], animated: false)
    }
}
