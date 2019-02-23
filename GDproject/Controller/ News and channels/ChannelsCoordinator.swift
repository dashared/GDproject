//
//  ChannelsCoordinator.swift
//  GDproject
//
//  Created by cstore on 23/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

final class ChannelsCoordinator{
    
    // MARK: - Properties
    private var channel: Channel { didSet { updateInterfaces() } }
    private weak var navigationController: UINavigationController?
    
    // MARK:- Init
    init(currentChannel: Channel, navigationController: UINavigationController) {
        self.channel = currentChannel
        self.navigationController = navigationController
    }
    
    func start(){
        showCurrentChannel()
    }
    
    // MARK: - Private implementation
    private func showListOfChannels(){
        let controller = UIStoryboard.makeChannelsListController()
        controller.onChannelSelected = { [weak self] channel
            in
            self?.channel = channel
            _ = self?.navigationController?.popViewController(animated: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showCurrentChannel(){
        let controller = UIStoryboard.makeNewsController()
        controller.channel = channel
        controller.onSelectChannel = { [weak self] in
            self?.showListOfChannels()
        }
        navigationController?.setViewControllers([controller], animated: false)
        //navigationController?.pushViewController(controller, animated: false)
    }
    
    // MARK:- update only viewControllers which are depandable on chosen channel
    private func updateInterfaces() {
        navigationController?.viewControllers.forEach {
            ($0 as? UpdateableWithChannel)?.channel = channel
        }
    }
}
