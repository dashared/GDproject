//
//  LogInCoordinator.swift
//  GDproject
//
//  Created by cstore on 23/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class LogInCoordinator{
    
    private weak var navigationController: UINavigationController?
    private var window: UIWindow!
    // MARK:- Init
    init(navigationController: UINavigationController, window: UIWindow) {
        self.navigationController = navigationController
        self.window = window
    }
    
    func start(){
        showLogInPage()
    }
    
    // MARK: - Private implementation
    private func showStatusPage(){
        let controller = TabbarCoordinator(window: window)
        controller.start()
    }
    
    private func showLogInPage(){
        let controller = UIStoryboard.makeLogIn()
        controller.onLogIn = {
            (id) in
            Model.authenticate(with: id) {
                (res) in
                if (res) { DataStorage.standard.setUserKey(with: id) }
                controller.authenticateSucceeded = res
            }
        }
        
        navigationController?.pushViewController(controller, animated: false)
    }
    
}
