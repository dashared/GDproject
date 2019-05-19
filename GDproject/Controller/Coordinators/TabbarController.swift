//
//  TabbarController.swift
//  RxSwift
//
//  Created by cstore on 03/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

protocol TabbarView: class {
    var onChannelsFlowSelect: ((UINavigationController) -> ())? { get set }
    var onProfileFlowSelect: ((UINavigationController) -> ())? { get set }
    var onMessagesFlowSelect: ((UINavigationController) -> ())? { get set }
    var onViewDidLoad: ((UINavigationController) -> ())? { get set }
}

final class TabbarController: UITabBarController, UITabBarControllerDelegate, TabbarView {
    
    
    var onChannelsFlowSelect: ((UINavigationController) -> ())?
    var onProfileFlowSelect: ((UINavigationController) -> ())?
    var onMessagesFlowSelect: ((UINavigationController) -> ())?
    
    var onViewDidLoad: ((UINavigationController) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        delegate = self
        if let controller = customizableViewControllers?.first as? UINavigationController {
            onViewDidLoad?(controller)
        }
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        
        guard let controller = viewControllers?[selectedIndex] as? UINavigationController else { return }
        
        if selectedIndex == 0 {
            onChannelsFlowSelect?(controller)
        } else if selectedIndex == 2 {
            onProfileFlowSelect?(controller)
        } else {
            onMessagesFlowSelect?(controller)
        }
    }
}
