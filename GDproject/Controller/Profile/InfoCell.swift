//
//  BasicInfoCell.swift
//  NewsFeed
//
//  Created by cstore on 23/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class InfoCell: UITableViewCell{
    
    var textView: UITextView = {
        let label = UITextView()
        label.font = UIFont.systemFont(ofSize: 16)
        label.sizeToFit()
        label.isScrollEnabled = false
        // label.isUserInteractionEnabled = false
        label.isEditable = false
        label.dataDetectorTypes = .all
        label.textColor =  .black
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func setUpView()
    {
        addSubview(textView)
        textView.horizontalToSuperview(insets: .left(32) + .right(16))
        textView.verticalToSuperview(insets: .top(8) + .bottom(8))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func fill(title: String){
        setUpView()
        textView.text = title
    }
}
