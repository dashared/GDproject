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

protocol ChannelListData: class {
    func reloadData (with channels: [Model.Channels])
}

// TODO: make search controller availiable
class ChannelListController: UITableViewController {
    
    // MARK: - Output -
    var onChannelSelected: ((Model.Channels) -> Void)?
    var onEditingModeBegins: ((Model.Channels, IndexPath)->Void)?
    
    // MARK: - filter search controller
    var filteredDataSource = [Model.Channels]()
    
    var displayingChannel: Model.Channels?
    
    var toReload: Bool = false {
        didSet {
            tableView.reloadData()
        }
    }
    
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
        // dataSource[row] = channel
    }
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Model.usersAllGet()
        
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
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        searchController.isActive = false
        askForUpdates()
    }
    
    func askForUpdates(){
        Model.channelsList { [weak self] (channels) in
            self?.dataSource = [ChannelListController.generalChannel] + channels
            self?.toReload = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //askForUpdates()
        tabBarController?.tabBar.isHidden = false
    }
    
    @objc func addChannel()
    {
        // editing mode is on automatically
        onEditingModeBegins?(Model.Channels(people: [], name: "Untitled", id: 0, tags: []),IndexPath(row: 1, section: 0))
    }
    
    static let generalChannel = Model.Channels(people: [], name: "General", id: -1, tags: [])
    
    var dataSource : [Model.Channels] = [ ChannelListController.generalChannel ]
    
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
        let editButton = UITableViewRowAction(style: .normal, title: "Edit") { [unowned self] (rowAction, indexPath) in
            self.onEditingModeBegins?(self.dataSource[indexPath.row], indexPath)
        }
        
        editButton.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        let deleteButton = UITableViewRowAction(style: .normal, title: "Delete") { [weak self] (action, indexPath) in
            
            Model.channelsDelete(by: self!.dataSource[indexPath.row].id!, completion: {
                print("хз что тут делать при успехе")
            })

            self?.tableView.beginUpdates()
            self?.dataSource.remove(at: indexPath.row)
            self?.tableView.deleteRows(at: [indexPath], with: .none)
            self?.tableView.endUpdates()
        }
        
        deleteButton.backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        
        return [editButton, deleteButton]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isFiltering {
            onChannelSelected?(filteredDataSource[indexPath.row])
        } else {
            onChannelSelected?(dataSource[indexPath.row])
        }
    }
}


extension ChannelListController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
