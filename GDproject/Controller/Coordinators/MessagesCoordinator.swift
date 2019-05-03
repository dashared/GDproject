//
//  MessagesCoordinator.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//


import Foundation
import UIKit

class MessagesCoordinator: BaseCoordinator {
    
    var didEndSession: (()->())?
    
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private weak var navigationController: UINavigationController?
    
    init(nc: UINavigationController) {
        self.navigationController = nc
    }
    
    override func start() {
        show()
    }
    
    private func show(){
        let vc = storyboard.instantiateViewController(withIdentifier: messagesViewControllerId) as! MessagesViewController
        
        // choose person to write message to
        vc.onUserDisplayList = { [weak vc, unowned self] in
            
            let newVC = self.storyboard.instantiateViewController(withIdentifier: peopleToWriteVC) as! PeopleToWriteViewController
            vc?.navigationController?.pushViewController(newVC, animated: true)
        }
        
        vc.onDialogDisplay = { [weak vc, unowned self] _ in
            let newVC = self.storyboard.instantiateViewController(withIdentifier: dialogVC) as! DialogViewController
            //newVC.currentDialog = $0
            vc?.navigationController?.pushViewController(newVC, animated: true)
        }
        navigationController?.viewControllers = [vc]
    }
}
