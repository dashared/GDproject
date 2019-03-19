//
//  LogInCoordinator.swift
//  RxSwift
//
//  Created by cstore on 01/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class LogInCoordinator: BaseCoordinator {
    
    var didEndFlow: (()->())?
    var window: UIWindow!
    var navigationController: UINavigationController?
    
    init(window: UIWindow) {
        self.window = window
        self.window?.rootViewController = UINavigationController()
        self.navigationController = window.rootViewController as? UINavigationController
    }
    
    override func start(){
        let logInVC = LogInViewController()
        logInVC.authenticate = { [weak self] (id) in
            
            Model.authenticate(with: id) {
                (res) in
                
                if (res) {
                    DataStorage.standard.setUserKey(with: id)
                    self?.didEndFlow?()
                }
                else {
                    DataStorage.standard.setUserKey(with: 0)
                }
            }
        }
        navigationController?.pushViewController(logInVC, animated: false)
    }
}
