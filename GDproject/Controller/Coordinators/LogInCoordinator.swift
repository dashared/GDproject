//
//  LogInCoordinator.swift
//  RxSwift
//
//  Created by cstore on 01/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class LogInCoordinator: BaseCoordinator {
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
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
        logInVC.authenticate = { [weak self, weak logInVC] (email) in
            
            Model.authenticate(with: email) { [weak self]
                (authStatus) in
                
                print(authStatus.userStatus)
                
                if (authStatus.userStatus == "invalid") {
                    logInVC?.mailTextField.text = "invalid"
                }
                else if (authStatus.userStatus == "canRegister") { // register form
                    self?.presentRegisterVC()
                } else { // validation code
                    self?.presentViewControllerForCodeInput()
                }
            }
        }
        
        navigationController?.pushViewController(logInVC, animated: false)
    }
    
    func presentViewControllerForCodeInput()
    {
        let vc = storyboard.instantiateViewController(withIdentifier: "CodeViewController") as! CodeViewController
        self.navigationController?.pushViewController(vc, animated: true)
        vc.onSuccessLogIn = {
            [weak self] in self?.didEndFlow?()
        }
    }
    
    func presentRegisterVC(){
        
        let vc1 = storyboard.instantiateViewController(withIdentifier: "RegisterTableViewController") as! RegisterTableViewController
        
        vc1.onRegistration = { [weak self] in
            self?.presentViewControllerForCodeInput()
        }
        
        self.navigationController?.pushViewController(vc1, animated: true)
    }
    
    
}
