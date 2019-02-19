//
//  ChannelListController.swift
//  GDproject
//
//  Created by cstore on 19/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

struct ChannelData{
    var title = String()
    var subtitle = String()
}

// TODO: make search controller availiable
class ChannelListController: UITableViewController{
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        navigationItem.title = "Channels"
        
        searchController.searchBar.placeholder  = "Search anything"
        navigationItem.searchController = searchController
    }
    
    func setUpNavigationBar(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))]
    }
    
    @objc func addChannel(){
        print("Add channel")
    }
    
    var dataSource: [ChannelData] = [ ChannelData(title: "Channel 1", subtitle: "Some info about channel"),
                                      ChannelData(title: "Channel 2", subtitle: "Some info about channel"),
                                      ChannelData(title: "Channel 3", subtitle: "Some info about channel")]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellId, for: indexPath)
        cell.textLabel?.text = dataSource[indexPath.row].title
        cell.detailTextLabel?.text = dataSource[indexPath.row].subtitle
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: channelControllerId) as! ChannelController
            
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        editButton.backgroundColor = .green
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { [weak self] (action, indexPath) in
            self?.tableView.beginUpdates()
            self?.dataSource.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
            self?.tableView.endUpdates()
        }
        deleteButton.backgroundColor = .red
        
        return [editButton, deleteButton]
    }
}
