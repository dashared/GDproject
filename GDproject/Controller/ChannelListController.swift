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
class ChannelListController: UITableViewController, DataDelegate {
    
    func passData(for row: Int, channel: Channel) {
        ChannelListController.dataSource[row].hashtags = channel.hashtags
        ChannelListController.dataSource[row].people = channel.people
        ChannelListController.dataSource[row].title = channel.title
        ChannelListController.dataSource[row].subtitle = channel.subtitle
    }
    
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
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    @objc func addChannel()
    {
        // insertion
        tableView.beginUpdates()
        ChannelListController.dataSource.insert(Channel(title: "Untitled", subtitle: "No", hashtags: [], people: []), at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
        tableView.endUpdates()
        
        // editing mode is one automatically
        let vc = storyboard?.instantiateViewController(withIdentifier: channelControllerId) as! ChannelController
        vc.index = 0
        vc.myProtocol = self
        vc.channel = ChannelListController.dataSource[0]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    static var dataSource : [Channel] = [
        Channel(title: "Title", subtitle: "subtitle", hashtags: ["# sad", "# happy"], people: ["Seva", "Andrey"]),
        Channel(title: "Title2", subtitle: "subtitle2", hashtags: ["# studyhard", "# university"], people: ["Pasha", "Olya", "Andrey", "Ilya"]),
        Channel(title: "Title3", subtitle: "subtitle3", hashtags: ["# lol", "# meme", "# hehe"], people: ["Superman"])
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChannelListController.dataSource.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellId, for: indexPath)
        cell.textLabel?.text = ChannelListController.dataSource[indexPath.row].title
        cell.detailTextLabel?.text = ChannelListController.dataSource[indexPath.row].subtitle
        
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        
        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { [weak self] (action, indexPath) in
            let vc = self?.storyboard?.instantiateViewController(withIdentifier: channelControllerId) as! ChannelController
            vc.index = indexPath.row
            vc.myProtocol = self!
            vc.channel = ChannelListController.dataSource[indexPath.row]
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        editButton.backgroundColor = .green
        
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { [weak self] (action, indexPath) in
            self?.tableView.beginUpdates()
            ChannelListController.dataSource.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
            self?.tableView.endUpdates()
        }
        deleteButton.backgroundColor = .red
        
        
        return [editButton, deleteButton]
    }
}
