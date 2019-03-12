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
    var onChannelSelected: ((Model.Channels) -> Void)?
    
    // MARK: - filter search controller
    var filteredDataSource = [Model.Channels]()
    
    var myProtocol: DataDelegate?
    var displayingChannel: Model.Channels?
    
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredDataSource = dataSource.filter({(keys : Model.Channels) -> Bool in
            return keys.name.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
    
    func passData(for row: Int, channel: Model.Channels) {
        dataSource[row] = channel
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
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))]
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        searchController.isActive = false
        Model.channelsList { [weak self] (channels) in
            self?.dataSource = [ChannelListController.generalChannel] + channels
        }
    }
    
    @objc func addChannel()
    {
        // editing mode is on automatically
        let vc = storyboard?.instantiateViewController(withIdentifier: channelControllerId) as! ChannelController
        vc.index = 1
        vc.myProtocol = self
        vc.channel = Model.Channels(people: [], name: "Untitled", tags: [])
        navigationController?.pushViewController(vc, animated: true)
    }
    
    static let generalChannel = Model.Channels(people: [], name: "General", id: -1, tags: [])
    
    var dataSource : [Model.Channels] = [
        Model.Channels(people: [], name: "General", id: -1, tags: [])
        ]
    {
        didSet{
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredDataSource.count
        } else {
            return dataSource.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellId, for: indexPath)
        
        
        if isFiltering{
            cell.textLabel?.text = filteredDataSource[indexPath.row].name
            cell.detailTextLabel?.text = filteredDataSource[indexPath.row].tags.reduce(String(), { (r, next) -> String in "\(r) \(next)" })
        } else {
            cell.textLabel?.text = dataSource[indexPath.row].name
            cell.detailTextLabel?.text = dataSource[indexPath.row].tags.reduce(String(), { (r, next) -> String in "\(r) \(next)" })
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
            vc.channel = self?.dataSource[indexPath.row]
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        editButton.backgroundColor = .green
        
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { [weak self] (action, indexPath) in
            if (self!.dataSource[indexPath.row].id == self!.displayingChannel?.id ?? -1)
            {
                self?.myProtocol?.passData(for: 0, channel: self!.dataSource[0])
            }
            self?.tableView.beginUpdates()
            self?.dataSource.remove(at: indexPath.row)
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
            myProtocol?.passData(for: 0, channel: dataSource[indexPath.row])
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
