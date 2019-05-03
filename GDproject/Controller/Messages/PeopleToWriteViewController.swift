//
//  PeopleToWriteViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class PeopleToWriteViewController: UITableViewController {
    
    // TODO: - edit button when it's used for selection 
    
    let searchC = UISearchController(searchResultsController: nil)
    
    let users = Model.Channels.fullPeople
    
    var chosenUsers: [Int: Model.UserPermission] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isEditing = true
        self.navigationItem.title = "People"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(newMessage))
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.searchController = searchC
        self.navigationItem.hidesSearchBarWhenScrolling = false
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(true, animated: animated)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return users.count
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenUsers[users[indexPath.row].id] = Model.UserPermission(isAdmin: false)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "peopleToWriteCell", for: indexPath)
        
        cell.textLabel?.text = users[indexPath.row].fullName()
        cell.detailTextLabel?.text = "\(users[indexPath.row].id)"

        return cell
    }
 
    @objc func newMessage()
    {
        if chosenUsers.count != 0
        {
            navigationController?.popViewController(animated: false)
            var group = Model.Group(users: chosenUsers, name: "Untitled", id: 0)
            
            Model.createGroupChat(from: group) { [unowned self] (id) in
                let vc = self.storyboard?.instantiateViewController(withIdentifier: dialogViewController) as! DialogViewController
                group.id = id
                vc.group = group
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
}
