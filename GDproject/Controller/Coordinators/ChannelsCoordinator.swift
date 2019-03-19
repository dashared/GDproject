//
//  ChannelsCoordinator.swift
//  RxSwift
//
//  Created by cstore on 03/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

class ChannelsCoordinator: BaseCoordinator{
    private weak var navigationController: UINavigationController?
    
    init(nc: UINavigationController) {
        self.navigationController = nc
    }
    
    override func start() {
        show()
    }
    
    private func show() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let channels = storyboard.instantiateViewController(withIdentifier: channelListControllerId) as! ChannelListController
        navigationController?.setViewControllers([channels], animated: false)
    }
}
