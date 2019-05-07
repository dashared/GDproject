//
//  MessagesViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class MessagesViewController: UITableViewController {

    // curreent Active which can be displayed
    var currentActiveDialogs: [Model.Dialog] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    // curreent users
    var users: [Int: Model.Users] = [:]
    
    var onUserDisplayList: (()->())?
    
    var onDialogDisplay: (((dialog: Model.Dialog, users: [Int:Model.Users]))->())?
    
    let searchC = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Write", style: .plain, target: self, action: #selector(choosePerson))
        
        self.navigationItem.title = "Messages"
        // self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.searchController = searchC
        navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    @objc func choosePerson(){
        onUserDisplayList?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        Model.getChatAll { [weak self]  in
            self?.currentActiveDialogs = $0.0
            self?.users = $0.1
        }
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentActiveDialogs.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessagesCell", for: indexPath)
        
        switch currentActiveDialogs[indexPath.row].self {
            
        case .groupChat(let group):
            cell.textLabel?.text = group.group.name
            cell.detailTextLabel?.text = group.lastMessage!.body.markdown
        case .userChat(let userChat):
            cell.textLabel?.text = "👤 \(users[userChat.user]!.fullName())"
            cell.detailTextLabel?.text = userChat.lastMessage.body.markdown
        }

        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuple = (currentActiveDialogs[indexPath.row],users)
        onDialogDisplay?(tuple)
    }
}
