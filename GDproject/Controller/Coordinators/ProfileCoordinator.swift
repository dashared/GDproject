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
        
        profile.logOut  = {
            Model.logout() {
                [weak self] in
                
                DataStorage.standard.setIsLoggedIn(value: false, with: 0)
                self?.didEndSession?()
            }
        }
        
        profile.deleteAllSessions = {
            Model.deactivateAll() {
                [weak self] in
                
                DataStorage.standard.setIsLoggedIn(value: false, with: 0)
                self?.didEndSession?()
            }
        }
        
        profile.onSettings = { [weak self, weak storyboard, weak profile] in
            
            let vc = storyboard?.instantiateViewController(withIdentifier: "RegisterTableViewController") as! RegisterTableViewController
            vc.delegate = profile
            vc.userActive = profile?.user
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        
        navigationController?.setViewControllers([profile], animated: false)
    }
}
