//
//  DialogCell.swift
//  GDproject
//
//  Created by cstore on 05/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints
import MarkdownKit

class DialogCell: UITableViewCell {

    let nameLabel: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(displayProfile), for: .touchUpInside)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return button
    }()
    
    @objc func displayProfile()
    {
        if let id = self.user?.id{
            onUserDisplay?(id)
        }
    }
    
    var onUserDisplay: ((Int)->())?

    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9)
        label.textAlignment = NSTextAlignment.right
        label.textColor = #colorLiteral(red: 0.4352941176, green: 0.4431372549, blue: 0.4745098039, alpha: 1)
        return label
    }()
    
    func createTextView(with text: NSAttributedString, _ isSelectable: Bool) -> UITextView
    {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.sizeToFit()
        
        if isSelectable {
            textView.isSelectable = true
        } else {
            textView.isUserInteractionEnabled = false
        }
        
        textView.attributedText = text
        return textView
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    var user: Model.Users? {
        didSet{
            nameLabel.setTitle(user!.fullName(), for: .normal)
        }
    }
    
    var textView: UITextView!
    
    func fill(with markdownText: NSAttributedString, byUser: Model.Users, when: String)
    {
        let myId = DataStorage.standard.getUserId()
        // important
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        self.user = byUser
        textView = createTextView(with: markdownText, true)
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        
        self.contentView.addSubview(textView)
        self.contentView.addSubview(timeLabel)
        
        timeLabel.text = when.getDate()
        textView.width(min: 50, max: self.contentView.bounds.width-70, priority: .required, isActive: true)
        
        if myId == byUser.id
        {
            layoutMyMessage()
        } else {
            layOutOtherMessage()
        }
    }
    
    func layOutOtherMessage(){
        self.contentView.addSubview(nameLabel)
        
        nameLabel.setTitle(user!.fullName(), for: .normal)
        
        nameLabel.edgesToSuperview(excluding: .bottom, insets: .top(4) + .left(8))
        textView.edgesToSuperview(excluding: [.top, .right] , insets: .left(8) + .bottom(20))
        textView.topToBottom(of: nameLabel)
        
        textView.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        textView.textColor = .white
        timeLabel.edgesToSuperview(excluding: .top, insets: .right(70) + .left(4))
        timeLabel.topToBottom(of: textView, offset: 4)
        timeLabel.textAlignment = .left
    }
    
    func layoutMyMessage()
    {
        textView.edgesToSuperview(excluding: .left, insets: .right(8) + .bottom(20) + .top(4))
        textView.backgroundColor = UIColor(red:0.08, green:0.49, blue:0.98, alpha:1.0)
        textView.textColor = .white
        timeLabel.edgesToSuperview(excluding: .top, insets: .left(70) + .right(4))
        timeLabel.topToBottom(of: textView, offset: 4)
    }
}



