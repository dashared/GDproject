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
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        label.text = "Богомазова Вероника Львовна"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return label
    }()
    
    func createTextView(with text: NSAttributedString, _ isSelectable: Bool) -> UITextView
    {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        
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
    
    func fill(with markdownText: NSAttributedString, byUser: Model.Users)
    {
        // important
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        self.user = byUser
        let textView = createTextView(with: markdownText, true)
        
        self.contentView.addSubview(nameLabel)
        self.contentView.addSubview(textView)
        nameLabel.edgesToSuperview(excluding: .bottom, insets: .top(8) + .left(8))
        textView.edgesToSuperview(excluding: .top, insets: .right(8) + .left(8) + .bottom(8))
        textView.topToBottom(of: nameLabel)
    }
}
