//
//  ChannelsCoordinator.swift
//  RxSwift
//
//  Created by cstore on 03/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit
import Pulley

class ChannelsCoordinator: BaseCoordinator{
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    private weak var navigationController: UINavigationController?
    
    init(nc: UINavigationController) {
        self.navigationController = nc
        navigationController?.navigationItem.largeTitleDisplayMode = .always
    }
    
    override func start() {
        show()
    }
    
    private func show() {
        
        let channels = storyboard.instantiateViewController(withIdentifier: channelListControllerId) as! ChannelListController
        
        channels.onChannelSelected = { [unowned self]
            (channel) in
            self.navigationController?.pushViewController(self.presentNewsController(with: channel), animated: true)
        }
        
        channels.askForUpdates()
        
        channels.onEditingModeBegins = { [unowned self] (channel, indexPath) in
            let vc = self.presentChannelController(with: channel)
            self.navigationController?.pushViewController(vc, animated: true)
            vc.tabBarController?.tabBar.isHidden = true
        }
        
        let nc = presentNewsController()
        navigationController?.setViewControllers([channels, nc], animated: false)
    }
    
    /// Function that presents channel controller
    ///
    /// - Parameter channel: channel that needs to be displayed
    func presentChannelController(with channel: Model.Channels? = nil) -> ChannelViewController {
        let mainContentVC = storyboard.instantiateViewController(withIdentifier: channelViewControllerId) as! ChannelViewController
        
        // to show preview we need to instantiate newsController but with different functionality
        mainContentVC.onShowingPreview = { [weak mainContentVC, unowned self] ch in
            let vc = self.presentNewsController(with: ch, previewMode: true)
            mainContentVC?.navigationController?.pushViewController(vc, animated: true)
        }
        mainContentVC.channel = channel
        return mainContentVC
    }
    
    func presentNewsController(with channel: Model.Channels? = nil, previewMode: Bool = false) -> NewsController
    {
        let mainContentVC = storyboard.instantiateViewController(withIdentifier: newsController) as! NewsController
        mainContentVC.channel = channel
        
        if !previewMode {
            mainContentVC.news.onFullPost = {
                [weak self] (type,post) in
                
                let vc = self?.storyboard.instantiateViewController(withIdentifier: fullPostControllerId) as! FullPostController
                vc.type = type
                vc.post = post
                self?.navigationController!.pushViewController(vc, animated: true)
            }
            
            mainContentVC.news.onChannelDidChange = {
                print("anon with \($0.0.count) users")
            }
            
            mainContentVC.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(writePost(_:)))
            ]
        }
        
        mainContentVC.changedChannelName = {
            [weak mainContentVC] (title) in mainContentVC?.navigationItem.title = title
        }
        
        return mainContentVC
    }
    
    @objc private func writePost(_ barItem: UIBarButtonItem)
    {
        let vc = storyboard.instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: vc, action: #selector(vc.newPost))
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: vc, action: #selector(vc.closeView))
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
        
        vc.moveBackToParentVC = {
            [weak self] in
            
            let transition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromBottom
            self?.navigationController?.view.layer.add(transition, forKey: nil)
            self?.navigationController?.popViewController(animated: false)
        }
    }
}
