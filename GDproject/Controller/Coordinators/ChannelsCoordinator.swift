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
        
        channels.onChannelSelected = { [weak self]
            (channel) in
            self?.navigationController?.pushViewController(self!.presentNewsController(with: channel), animated: true)
        }
        navigationController?.setViewControllers([channels,presentNewsController()], animated: false)
    }
    
    func presentNewsController(with channel: Model.Channels? = nil) -> PulleyViewController {
        
        let mainContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: newsController) as! NewsController
        let drawerContentVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DrawerContentViewController")
        
        mainContentVC.channel = channel
        mainContentVC.news.onFullPost = {
            [weak self] (type,post) in
            
            let vc = self?.storyboard.instantiateViewController(withIdentifier: fullPostControllerId) as! FullPostController
            vc.type = type
            vc.post = post
            self?.navigationController!.pushViewController(vc, animated: true)
        }
        
        mainContentVC.news.onChannelDidChange = {
            [weak self, weak mainContentVC] (tuple) in print("hep")
            switch mainContentVC!.news.type {
            case .ANONYMOUS:
                mainContentVC!.posts = tuple.1
                mainContentVC!.dictionary = tuple.0
            default:
                let vc = self!.presentNewsController()
                (vc.primaryContentViewController as! NewsController).anonymousChannel = tuple
                (vc.primaryContentViewController as! NewsController).type = .ANONYMOUS
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
        let pulleyDrawerVC = PulleyViewController(contentViewController: mainContentVC, drawerViewController: drawerContentVC)
        
        pulleyDrawerVC.initialDrawerPosition = .collapsed
        mainContentVC.changedChannelName = {
            [weak pulleyDrawerVC] (title) in pulleyDrawerVC?.navigationItem.title = title
        }
        
        pulleyDrawerVC.navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(writePost(_:)))
        ]
        
        return pulleyDrawerVC
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
