//
//  ApplicationCoordinator.swift
//  RxSwift
//
//  Created by cstore on 04/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit



fileprivate enum LaunchInstructor {
    case main, auth
    
    static func configure(
        isAutorized: Bool = DataStorage.standard.isLoggedIn) -> LaunchInstructor {
        
        if isAutorized{
            return .main
        } else {
            return .auth
        }
    }
}

final class ApplicationCoordinator: BaseCoordinator{
    private var window: UIWindow!
    
    init(window: UIWindow) {
        self.window = window
    }
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
    override func start() {
        switch instructor {
        case .auth: runAuthFlow()
        case .main: runMainFlow()
        }
    }
    
    private func runAuthFlow() {
        let coordinator = LogInCoordinator(window: window)
        coordinator.didEndFlow = { [weak self, weak coordinator] in
            self?.start()
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func runMainFlow() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBar = storyboard.instantiateViewController(withIdentifier: "TabbarController") as! TabbarController
        let coordinator = TabBarCoordinator(tabbarView: tabBar, window: window!)
        
        coordinator.didEndFlow = { [weak self, weak coordinator] in
            self?.start()
            self?.removeDependency(coordinator)
        }
        
        addDependency(coordinator)
        coordinator.start()
    }
}
