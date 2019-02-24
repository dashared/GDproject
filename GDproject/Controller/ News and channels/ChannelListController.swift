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
    
    // MARK: - Output -
    var onChannelSelected: ((Channel) -> Void)?
    
    // MARK:- filter search controller
    var filteredDataSource = [Channel]()
    
    var myProtocol: DataDelegate?
    var displayingChannel: Channel?
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredDataSource = ChannelListController.dataSource.filter({(keys : Channel) -> Bool in
            return keys.title.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func passData(for row: Int, channel: Channel) {
        ChannelListController.dataSource[row] = channel
    }
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationBar()
        navigationItem.title = "Channels"
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Search channel"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func setUpNavigationBar(){
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))]
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        searchController.isActive = false
        tableView.reloadData()
    }
    
    @objc func addChannel()
    {
        // insertion
        tableView.beginUpdates()
        ChannelListController.dataSource.insert(Channel(title: "Untitled", subtitle: "No", hashtags: [], people: [], posts: []), at: 1)
        tableView.insertRows(at: [IndexPath(row: 1, section: 0)], with: .none)
        tableView.endUpdates()
        
        // editing mode is on automatically
        let vc = storyboard?.instantiateViewController(withIdentifier: channelControllerId) as! ChannelController
        vc.index = 1
        vc.myProtocol = self
        vc.channel = ChannelListController.dataSource[1]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    static var dataSource : [Channel] = [
        Channel(title: "General", subtitle: "All posts", hashtags: ["All"], people: ["All"], posts: [])
    ]
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredDataSource.count
        } else {
            return ChannelListController.dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellId, for: indexPath)
        
        
        if isFiltering{
            cell.textLabel?.text = filteredDataSource[indexPath.row].title
            cell.detailTextLabel?.text = filteredDataSource[indexPath.row].subtitle
        } else {
            cell.textLabel?.text = ChannelListController.dataSource[indexPath.row].title
            cell.detailTextLabel?.text = ChannelListController.dataSource[indexPath.row].subtitle
        }
        
        return cell
    }

    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        switch indexPath.row {
        case 0:
            return false
        default:
            return true
        }
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
            if (ChannelListController.dataSource[indexPath.row] == self!.displayingChannel!)
            {
                self?.myProtocol?.passData(for: 0, channel: ChannelListController.dataSource[0])
            }
            self?.tableView.beginUpdates()
            ChannelListController.dataSource.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
            self?.tableView.endUpdates()
        }
        deleteButton.backgroundColor = .red
        
        
        return [editButton, deleteButton]
    }
    
    // TODO: remove popping
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isFiltering {
            //onChannelSelected?(filteredDataSource[indexPath.row])
            myProtocol?.passData(for: 0, channel: filteredDataSource[indexPath.row])
            navigationController?.popViewController(animated: true)
        } else {
            myProtocol?.passData(for: 0, channel: ChannelListController.dataSource[indexPath.row])
            navigationController?.popViewController(animated: true)
            //onChannelSelected?(ChannelListController.dataSource[indexPath.row])
        }
    }
}


extension ChannelListController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
