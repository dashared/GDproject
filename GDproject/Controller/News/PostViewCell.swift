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
        label.text = "vbogomazova"
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
    
    let commentsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        return label
    }()
    
    let shareButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
        return button
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
    var post: Post?
    
    func fill(with info: [Media], _ isFullVersoin: Bool, post: Post)
    {
        self.post = post
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
        //nameStackView.height(46)
        nameStackView.edgesToSuperview(excluding: .bottom, insets: .left(20) + .right(20) + .top(8))
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        let scrollView = UIScrollView()
        
        scrollView.backgroundColor = .white
        
        mainView.addSubview(scrollView)
        scrollView.edgesToSuperview()
        
        scrollView.showsHorizontalScrollIndicator = false
        
        var buttons: [UIButton] = []
        for hash in post!.hashtags {
            let button = UIButton()
            button.setTitle("#" + hash, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(.black, for: .normal)
            buttons.append(button)
        }
        
        let stackViewHashTags = UIStackView(arrangedSubviews: buttons)
        
        scrollView.addSubview(stackViewHashTags)
        
        stackViewHashTags.axis = .horizontal
        stackViewHashTags.alignment = .center
        stackViewHashTags.spacing = 20
        
        stackViewHashTags.edgesToSuperview(insets: .left(20) + .top(10) + .right(20))
        
        scrollView.contentSize = CGSize(width: 500, height: 50)
        
        
        contentView.addSubview(mainView)
        mainView.edgesToSuperview(excluding: [.top, .bottom])
        mainView.topToBottom(of: nameStackView)
        mainView.height(50)
        
        let stackView = MyStackView(arrangedSubviews: views)
        stackView.isFull = full
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        if !full {
            stackView.height(300, relation: .equalOrLess, isActive: true)
        }
        stackView.topToBottom(of: mainView, offset: 16, relation: .equal, isActive: true)
        stackView.edgesToSuperview(excluding: [.top, .bottom], insets: .left(16) + .right(16))
        
        let commentsSharesStackView = UIStackView(arrangedSubviews: [ commentsLabel, shareButton])
        contentView.addSubview(commentsSharesStackView)
        
        commentsLabel.text = "14.02.19 в 23:00"
        commentsSharesStackView.axis = .horizontal
        commentsSharesStackView.distribution = .equalSpacing
        commentsSharesStackView.edgesToSuperview(excluding: .top, insets: .bottom(10) + .left(16) + .right(16))
        stackView.bottomToTop(of: commentsSharesStackView)
    }
}
