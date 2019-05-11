//
//  PostViewCell.swift
//  GDproject
//
//  Created by cstore on 04/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import Cartography
import TinyConstraints

class PostViewCell: UITableViewCell
{
    
    var onUserDisplay: ((Int)->())?
    
    var onAnonymousChannelDisplay: ((String)->())?
    
    let nameLabel: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.contentHorizontalAlignment = UIControl.ContentHorizontalAlignment.left
        return button
    }()
    
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
    
    let shareButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
        button.isHidden = true
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
    
    func createTextView(with text: NSAttributedString, _ isSelectable: Bool) -> UITextView
    {
        let textView = UITextView()
        textView.isScrollEnabled = false
        textView.isEditable = false
        if isSelectable {
            //textView.isUserInteractionEnabled = false
            textView.isSelectable = true
        } else {
            textView.isUserInteractionEnabled = false
        }
        
        textView.attributedText = text
        return textView
    }
    
    var views: [UIView] = []
    var post: Model.Posts?
    
    func fill(with info: NSAttributedString, _ isFullVersoin: Bool, post: Model.Posts)
    {
        self.post = post
        // important
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        
        views = []
        views.append(createTextView(with: info, isFullVersoin))
        
        nameLabel.setTitle("\(post.user?.firstName ?? "") \(post.user?.lastName ?? "")", for: .normal)
        nameLabel.addTarget(self, action: #selector(displayProfile), for: .touchUpInside)
        if let user = post.user{
            fullNameLabel.text = "\(user.firstName) \(user.middleName) \(user.lastName)"
        }
        else {
            fullNameLabel.text = "\(post.authorId)"
        }
    
        setUpInStackView(isFullVersoin)
    }
    
    var hashtags = [String]()
    
    func setUpInStackView(_ full : Bool){
        
        hashtags = post!.tags
        
        let nameStackView = UIStackView(arrangedSubviews: [nameLabel, fullNameLabel])
        nameStackView.axis = .vertical
        contentView.addSubview(nameStackView)
        //nameStackView.height(46)
        nameStackView.edgesToSuperview(excluding: .bottom, insets: .left(20) + .right(20) + .top(8))
        
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        
        let scrollView = UIScrollView()
        
        scrollView.backgroundColor = .white
        
        mainView.addSubview(scrollView)
        scrollView.edgesToSuperview()
        
        scrollView.showsHorizontalScrollIndicator = false
        
        var buttons: [UIButton] = []
        for hash in hashtags {
            let button = UIButton()
            button.setTitle("#" + hash, for: .normal)
            button.addTarget(self, action: #selector(setAnonymousChannel(on:)), for: .touchUpInside)
            // button.addGestureRecognizer(longPressRecognizer)
            button.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .semibold)
            button.setTitleColor(#colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), for: .normal)
            buttons.append(button)
        }
        
        let stackViewHashTags = UIStackView(arrangedSubviews: buttons)
        
        scrollView.addSubview(stackViewHashTags)
        
        stackViewHashTags.axis = .horizontal
        stackViewHashTags.spacing = 17
        
        // edgesToSuperview(insets: .left(20) + .top(10) + .right(20))
        stackViewHashTags.horizontalToSuperview(insets: .left(20) + .right(20))
        stackViewHashTags.verticalToSuperview()
        
        stackViewHashTags.distribution = .fillProportionally
        stackViewHashTags.alignment = .center
    
        scrollView.contentSize = CGSize(width: 500, height: 30)
        
        
        contentView.addSubview(mainView)
        mainView.edgesToSuperview(excluding: [.top, .bottom])
        mainView.topToBottom(of: nameStackView, offset: 5)
        
        // TODO:- change!!!!!!!!!!!!
        if hashtags.isEmpty{
            mainView.height(0)
        } else {
            mainView.height(30)
        }
        
        let stackView = MyStackView(arrangedSubviews: views)
        stackView.isFull = full
        stackView.axis = .vertical
        contentView.addSubview(stackView)
        if !full {
            stackView.height(300, relation: .equalOrLess, isActive: true)
        }

        stackView.topToBottom(of: mainView, offset: 0, relation: .equal, isActive: true)

        stackView.edgesToSuperview(excluding: [.top, .bottom], insets: .left(16) + .right(16))
        
        let commentsSharesStackView = UIStackView(arrangedSubviews: [ timeLabel, shareButton])
        contentView.addSubview(commentsSharesStackView)
        
        timeLabel.text = post!.convertDateFormatter()
        
        commentsSharesStackView.axis = .horizontal
        commentsSharesStackView.distribution = .equalSpacing
        commentsSharesStackView.edgesToSuperview(excluding: .top, insets: .bottom(10) + .left(16) + .right(16))
        stackView.bottomToTop(of: commentsSharesStackView)
    }
    
    @objc func displayProfile(){
        if let id = post?.authorId {
            onUserDisplay?(id)
        }
    }
    
    @objc func setAnonymousChannel(on button: UIButton){
        print("\(button.titleLabel?.text ?? "nothing")")
        onAnonymousChannelDisplay?(String(button.titleLabel!.text!.dropFirst()))
    }
}
