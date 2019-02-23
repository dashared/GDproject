//
//  BasicInfoCell.swift
//  NewsFeed
//
//  Created by cstore on 23/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class BasicInfoCell: UITableViewCell{
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor =  .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setUpView(){
        addSubview(titleLabel)
        titleLabel.horizontalToSuperview(insets: .left(16) + .right(16))
        titleLabel.verticalToSuperview(insets: .top(8) + .bottom(8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(title: String){
        setUpView()
        titleLabel.text = title
    }
}
