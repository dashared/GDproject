//
//  PostViewCell.swift
//  GDproject
//
//  Created by cstore on 04/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import Cartography
import MarkdownKit
import TinyConstraints

class PostViewCell: UITableViewCell
{
    let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.text = "vgogomazova"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }()
    
    let fullNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        label.text = "Богомазова Вероника Львовна"
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createTextView(with text: String) -> UITextView
    {
        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 16))
        let markdown = text
        markdownParser.enabledElements = .disabledAutomaticLink
        markdownParser.header.fontIncrease = 6
        markdownParser.code.textBackgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.attributedText = markdownParser.parse(markdown)
        return textView
    }
    
    var views: [UIView] = []
    var data : [UIImage] = []
    
    func fill(with info: [Media], _ isFullVersoin: Bool)
    {
        // important
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        data = []
        views = []
        for item in info.enumerated()
        {
            switch item.element
            {
            case .text(let text):
                views.append(createTextView(with: text))
            case .image(let images):
                self.data = images
            default:
                break
            }
        }
        setUpInStackView(isFullVersoin)
    }
    
    func setUpInStackView(_ full : Bool){
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, fullNameLabel])
        nameStackView.axis = .vertical
        contentView.addSubview(nameStackView)
        nameStackView.height(46)
        nameStackView.edgesToSuperview(excluding: .bottom, insets: .left(16) + .right(16))
        
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        if !full {
            stackView.height(300, relation: .equalOrLess, isActive: true)
        }
        stackView.topToBottom(of: nameStackView)
        stackView.edgesToSuperview(excluding: .top, insets: .bottom(8) + .left(16) + .right(16))
    }
}
