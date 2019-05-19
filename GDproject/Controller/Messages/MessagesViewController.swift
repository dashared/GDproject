//
//  MessagesViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol SelectableDialog: class {
    func openDialog(with dialog: Model.Dialog)
}

class MessagesViewController: UITableViewController, UISearchControllerDelegate, UISearchResultsUpdating, SelectableDialog {
    
    func openDialog(with dialog: Model.Dialog) {
        onDialogDisplay?((dialog, users))
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        let filteredData = currentActiveDialogs
        let inputText = searchController.searchBar.text ?? ""
        
        let filteredResults = filteredData.filter {
            
            switch $0 {
            case .groupChat(let gropuChat):
                return gropuChat.group.name.contains(inputText)
                
            case .userChat(let userChat):
                let user = users[userChat.user]
                guard let u = user else { return false }
                return u.fullName().contains(inputText)
                
            }
            
        }
        
        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? SuggestedDialogsTableViewController {
            resultsController.users = users
            resultsController.currentDialogs = filteredResults
            resultsController.tableView.reloadData()
        }
    }
    
    // curreent Active which can be displayed
    var currentActiveDialogs: [Model.Dialog] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    func setUpSearchContr(){
        
        searchController?.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = true
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.placeholder  = "Search dialogs"
        
    }
    
    // curreent users
    var users: [Int: Model.Users] = [:]
    
    var onUserDisplayList: (()->())?
    
    var onDialogDisplay: (((dialog: Model.Dialog, users: [Int:Model.Users]))->())?
    
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let updater = SuggestedDialogsTableViewController()
        
        updater.delegate = self
        searchController = UISearchController(searchResultsController: updater)
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Write", style: .plain, target: self, action: #selector(choosePerson))
        
        self.navigationItem.title = "Messages"
        // self.navigationItem.largeTitleDisplayMode = .always
        setUpSearchContr()
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageViewCell", for: indexPath) as! MessageViewCell
        
        switch currentActiveDialogs[indexPath.row].self {
        case .groupChat:
            cell.fill(with: currentActiveDialogs[indexPath.row])
        case .userChat(let userChat):
            cell.fill(with: currentActiveDialogs[indexPath.row], user: users[userChat.user])
        }
        
        return cell
    }
 
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tuple = (currentActiveDialogs[indexPath.row],users)
        onDialogDisplay?(tuple)
    }
}


class SuggestedDialogsTableViewController: UITableViewController {
    
    var idCell = "cell"
    
    var users: [Int: Model.Users] = [:]
    
    weak var delegate: SelectableDialog?
    
    var currentDialogs: [Model.Dialog] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: idCell)
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDialogs.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: idCell, for: indexPath)
        
        switch currentDialogs[indexPath.row] {
        case .groupChat(let groupChat):
            cell.textLabel?.text = groupChat.group.name
        case .userChat(let userChat):
            cell.textLabel?.text = users[userChat.user]?.fullName()
        }
        
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.openDialog(with: currentDialogs[indexPath.row])
        // self.dismiss(animated: true)
    }
}
