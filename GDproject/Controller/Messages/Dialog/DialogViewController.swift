//
//  DialogViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol UpdatableGroup:class  {
    func updateGroup(with group: Model.Group)
}

class DialogViewController: UITableViewController, UpdatableGroup {
    
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
    
    func setTitleForChat(userChat: Model.UserChat){
        navigationItem.title = "🌌 \(users![userChat.user]!.fullName())"
    }
    
    func setTitleForGroup(groupChat: Model.GroupChat){
        navigationItem.title = "🌌 \(groupChat.group.id) \(groupChat.group.name)"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(moveToInfoVC))
    }
    
    @objc func moveToInfoVC(){
        let vc = storyboard?.instantiateViewController(withIdentifier: chatInfoViewController) as! ChatInfoViewController
        
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

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
