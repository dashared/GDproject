//
//  ChannelsCoordinator.swift
//  RxSwift
//
//  Created by cstore on 03/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit
import Pulley

class ChannelsCoordinator: BaseCoordinator{
    private weak var navigationController: UINavigationController?
    
    init(nc: UINavigationController) {
        self.navigationController = nc
    }
    
    override func start() {
        show()
    }
    
    private func show() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let channels = storyboard.instantiateViewController(withIdentifier: channelListControllerId) as! ChannelListController
        
        let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: newsController) as! NewsController
        
        let drawerContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DrawerContentViewController")
        
        let pulleyDrawerVC = PulleyViewController(contentViewController: mainContentVC, drawerViewController: drawerContentVC)
        
        pulleyDrawerVC.initialDrawerPosition = .collapsed
        mainContentVC.changedChannelName = {
            [weak pulleyDrawerVC] (title) in pulleyDrawerVC?.navigationItem.title = title
        }
        
        navigationController?.setViewControllers([channels,pulleyDrawerVC], animated: false)
    }
}
