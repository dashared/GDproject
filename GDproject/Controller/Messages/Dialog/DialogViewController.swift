//
//  DialogViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

protocol UpdatableGroup:class  {
    func updateGroup(with group: Model.Group)
}

class DialogViewController: UIViewController, UpdatableGroup, UITableViewDelegate, UITableViewDataSource
{
    
    var tableView: UITableView = UITableView()
    
    func updateGroup(with group: Model.Group){
        self.groupChat?.group = group
        setTitleForGroup(groupChat: groupChat!)
    }
    
    let cellId = "cell3"
    var onInfoShow: (()->())?
    
    var dialog: Model.Dialog? {
        didSet{
            switch dialog! {
            case .groupChat(let chat):
                self.groupChat = chat
            case .userChat(let chat):
                self.userChat = chat
            }
        }
    }
    
    var groupChat: Model.GroupChat?
    var userChat: Model.UserChat?
    
    var users: [Int: Model.Users]?
    
    var groupId: Int?
    
    var cellData: [PostCellData] = [] {
        didSet {
            print(cellData)
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setConstraints()
        magicForKeyboardChanges()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self

        tabBarController?.tabBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
        
        tableView.register(DialogCell.self, forCellReuseIdentifier: cellId)
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.contentOffset = CGPoint(x: 0, y: -30)
        
        if let groupChat = groupChat {
            setTitleForGroup(groupChat: groupChat)
        } else if let userChat = userChat{
            setTitleForChat(userChat: userChat)
        }
    }
    
    var messageSendView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    var messageTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.backgroundColor = .green
        return textView
    }()
    
    var sendButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        return button
    }()
    
    @objc func sendMessage()
    {
        var destination: Model.MessageDestination?
        
        if let group = groupChat{
            destination = Model.MessageDestination.groupChatDestination(group.group.id)
        } else if let user = userChat {
            destination = Model.MessageDestination.userChatDestination(user.user)
        }
        
        if let destination = destination
        {
            Model.sendMessage(message: Model.SendMessage(body: Model.Attachments(markdown: messageTextView.text), destination: destination)) { [unowned self] in
                self.getMessages(for: self.dialog!)
            }
        }
    }
    
    var bottomConstraint: NSLayoutConstraint!
    
    func setConstraints(){
        self.view.addSubview(tableView)
        self.view.addSubview(messageSendView)
        
        messageSendView.addSubview(messageTextView)
        messageSendView.addSubview(sendButton)
        
        messageSendView.edgesToSuperview(excluding: [.top,.bottom])
        
        bottomConstraint = NSLayoutConstraint(item: messageSendView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint)
        
        messageSendView.height(40)
        
        sendButton.edgesToSuperview(excluding: .left)
        sendButton.width(60)
        
        messageTextView.edgesToSuperview(excluding: .right)
        messageTextView.rightToLeft(of: sendButton)
        
        tableView.edgesToSuperview(excluding: .bottom)
        tableView.bottomToTop(of: messageSendView)
        
        self.view.layoutSubviews()
    }
    
    func magicForKeyboardChanges()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotifications), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func handleKeyboardNotifications(notification: NSNotification){
        if let userInfo = notification.userInfo{
            // UIKeyboardFrameEndUserInfoKey
            
            let keyBoardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            
            bottomConstraint.constant = notification.name == UIResponder.keyboardWillShowNotification ? -(keyBoardFrame.height) : 0
            
            UIView.animate(withDuration: 0, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }) { (completed) in
                
            }
        }
    }
    
    func setTitleForChat(userChat: Model.UserChat){
        navigationItem.title = "🌌 \(users![userChat.user]!.fullName())"
    }
    
    func setTitleForGroup(groupChat: Model.GroupChat){
        navigationItem.title = "🌌 \(groupChat.group.id) \(groupChat.group.name)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(moveToInfoVC))
    }
    
    @objc func moveToInfoVC(){
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: chatInfoViewController) as! ChatInfoViewController
        
        vc.delegate = self
        vc.users = users!
        
        if let groupChat = groupChat {
            vc.groupChat = groupChat.group
        }

        navigationController?.pushViewController(vc, animated: true)
    }
    
    var currentMessagesInChat: [Model.LastMessage]? {
        didSet {
            if let currentMessagesInChat = currentMessagesInChat {
                cellData = currentMessagesInChat.map { PostCellData(attributedData: PostCellData.create(with: [$0.body])) }
            }
        }
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let dialog = dialog {
            getMessages(for: dialog)
        }
    }
    
    func getMessages(for dialog: Model.Dialog){
        switch dialog {
        case .groupChat(let groupChat):
            Model.getMessagesFor(typeOfChat: Model.Dialog.groupChat(groupChat), chat: groupChat.group.id)
            { [unowned self]  in
                self.currentMessagesInChat = $0
            }
        case .userChat(let userChat):
            Model.getMessagesFor(typeOfChat: Model.Dialog.userChat(userChat), chat: userChat.user)
            { [unowned self]  in
                self.currentMessagesInChat = $0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! DialogCell
        
        //In cellForRowAtIndexPath
        cell.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        if let author = currentMessagesInChat?[indexPath.row].author, let user = users?[author]
        {
            cell.fill(with: cellData[indexPath.row].attributedData, byUser: user)
        }
        
        return cell
    }
}



