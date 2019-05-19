//
//  TabBarCoordinator.swift
//  RxSwift
//
//  Created by cstore on 02/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit


class TabBarCoordinator: BaseCoordinator {
    
    var didEndFlow: (()->())?
    
    private let tabbarView: TabbarView
    private weak var window: UIWindow?
    
    init(tabbarView: TabbarView, window: UIWindow) {
        self.tabbarView = tabbarView
        self.window = window
    }
    
    override func start() {
        tabbarView.onViewDidLoad = runChannelsFlow()
        tabbarView.onChannelsFlowSelect = runChannelsFlow()
        tabbarView.onProfileFlowSelect = runProfileFlow()
        tabbarView.onMessagesFlowSelect = runMessagesFlow()
        window?.rootViewController = tabbarView as! TabbarController
    }
    
    private func runChannelsFlow() -> ((UINavigationController) -> ())
    {
        return { [unowned self] navController in
            if navController.viewControllers.isEmpty == true {
                let channelCoordinator = ChannelsCoordinator(nc: navController)
                self.addDependency(channelCoordinator)
                channelCoordinator.start()
            }
        }
    }
    
    private func runMessagesFlow() -> ((UINavigationController) -> ()){
        return { [unowned self] navController in
            if navController.viewControllers.isEmpty == true {
                let messagesCoordinator = MessagesCoordinator(nc: navController)
                self.addDependency(messagesCoordinator)
                messagesCoordinator.start()
            }
        }
    }
    
    private func runProfileFlow() -> ((UINavigationController) -> ())
    {
        return { [unowned self] navController in
            if navController.viewControllers.isEmpty == true {
                let profileCoordinator = ProfileCoordinator(nc: navController)
                profileCoordinator.didEndSession = { [weak self, weak profileCoordinator] in
                    self?.removeDependency(profileCoordinator)
                    self?.didEndFlow?()
                }
                self.addDependency(profileCoordinator)
                profileCoordinator.start()
            }
        }
    }
}
