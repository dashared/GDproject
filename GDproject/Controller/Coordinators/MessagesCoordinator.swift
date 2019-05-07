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
            
            newVC.whatToDoWithSelection = { [weak newVC, weak self] in
                newVC?.navigationController?.popViewController(animated: true)
                
                var group = Model.Group(users: $0, name: "Untitled", id: 0)
                Model.createGroupChat(from: group, completion:
                    { [weak self] id in
                        
                    let newVC1 = DialogViewController()
                    group.id = id
                    newVC1.dialog = Model.Dialog.groupChat(Model.GroupChat(group: group))
                    self?.navigationController?.pushViewController(newVC1, animated: true)
                })
            }
            
            vc?.navigationController?.pushViewController(newVC, animated: true)
        }
        
        vc.onDialogDisplay = { [weak vc]  in
            let newVC = DialogViewController()
            newVC.dialog = $0.dialog
            newVC.users = $0.users
            vc?.navigationController?.pushViewController(newVC, animated: true)
        }
        
        navigationController?.viewControllers = [vc]
    }
}
