//
//  ProfileCoordinator.swift
//  RxSwift
//
//  Created by cstore on 02/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

class ProfileCoordinator: BaseCoordinator {
    
    var didEndSession: (()->())?
    
    private weak var navigationController: UINavigationController?
    
    init(nc: UINavigationController) {
        self.navigationController = nc
    }
    
    override func start() {
        show()
    }
    
    private func show() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let profile = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        profile.logOut = { [weak self] in
            DataStorage.standard.setIsLoggedIn(value: false, with: 0)
            self?.didEndSession?()
        }
        profile.onSettings = { [weak self, weak storyboard] in
            let vc = storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        profile.onChannelsListToAddAPerson = { [weak self, weak storyboard] (user) in
            let vc = storyboard?.instantiateViewController(withIdentifier: simplifiedChannelsList) as! SimplifiedChannelsList
            vc.user = user
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.moveIn
            transition.subtype = CATransitionSubtype.fromTop
            self?.navigationController?.view.layer.add(transition, forKey: nil)
            self?.navigationController?.pushViewController(vc, animated: false)
        }
        navigationController?.setViewControllers([profile], animated: false)
    }
}
