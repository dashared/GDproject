//
//  HeaderNewsChannels.swift
//  GDproject
//
//  Created by cstore on 13/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class HeaderNewsChannels: UITableViewCell {
    
    weak var tableView: UITableView?
    
    weak var vc: NewsController?
    weak var vcProfile: ProfileViewController?
    
    var type: HeaderType = .PROFILE("Posts", "Channel")
    {
        didSet{
            switch type {
            case .PROFILE(let f, let s):
                postsChannelsSegment = UISegmentedControl(items: [f,s])
                postsChannelsSegment?.selectedSegmentIndex = 0
            case .BASIC_INFO(let b, let i):
                postsChannelsSegment = UISegmentedControl(items: [b,i])
                postsChannelsSegment?.selectedSegmentIndex = 1
            case .NEWS(let n, let bi):
                postsChannelsSegment = UISegmentedControl(items: [n, bi])
                postsChannelsSegment?.selectedSegmentIndex = 0
            default:
                break
            }
            setUpCell()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        //setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpCell(){
        
        guard let postsChannelsSegment = postsChannelsSegment else {
            return
        }
        
        addSubview(postsChannelsSegment)
        
        postsChannelsSegment.addTarget(self, action: #selector(changedValue), for: .valueChanged)
        postsChannelsSegment.edgesToSuperview(insets: .left(16) + .right(16) + .top(8) + .bottom(8))
    }
    
    // Initialize
    var postsChannelsSegment: UISegmentedControl?
    
    @objc func changedValue(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        switch index {
        case 0:
            switch type {
            case .BASIC_INFO:
                vcProfile?.changeToPosts()
            case .NEWS:
                vc?.setUpNavigationItemsforPosts()
            default:
                break
            }
        case 1:
            switch type {
            case .PROFILE:
                print("info")
                vcProfile?.changeToBasicInfo()
            case .NEWS:
                print("channels")
                vc?.setUpNavigationItemsForChannels()
            default:
                break
            }
        default:
            break
        }
    }
}

