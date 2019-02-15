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
    
    weak var vc: NewsController?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        setUpCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setUpCell(){
        addSubview(postsChannelsSegment)
        postsChannelsSegment.selectedSegmentIndex = 0
        postsChannelsSegment.addTarget(self, action: #selector(changedValue), for: .valueChanged)
        postsChannelsSegment.edgesToSuperview(insets: .left(16) + .right(16) + .top(8) + .bottom(8))
    }
    
    // Initialize
    let postsChannelsSegment = UISegmentedControl(items: ["Posts", "Channels"])
    
    @objc func changedValue(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        switch index {
        case 0:
            print("posts")
            vc?.setUpNavigationItemsforPosts()
        case 1:
            print("channels")
            vc?.setUpNavigationItemsForChannels()
        default:
            break
        }
    }
}

