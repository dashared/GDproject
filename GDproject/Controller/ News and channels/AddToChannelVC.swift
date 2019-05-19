//
//  AddToChannelVC.swift
//  GDproject
//
//  Created by cstore on 02/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

enum DataSourse{
    case people, tags
}

class AddToChannelVC: UITableViewController {
    
    var channel: Model.Channels?
    weak var update: UpdatableChannel?
    
    // data sources for people and hashtags
    var dataSourcePeople: [Model.Users] = Model.Channels.fullPeople
    
    var reloadtable: Bool = false {
        didSet{
            tableView.reloadData()
        }
    }
    
    var filteredDataSource = [Model.Users]()
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All")
    {
        filteredDataSource = dataSourcePeople.filter { $0.fullName().lowercased().contains(searchText.lowercased()) }
        tableView.reloadData()
    }

    let searchC = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "People"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationItem.searchController = searchC
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        searchC.searchResultsUpdater = self
        searchC.obscuresBackgroundDuringPresentation = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        update?.updateChannel(with: channel!)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    var isFiltering: Bool {
        return searchC.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchC.searchBar.text?.isEmpty ?? true
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredDataSource.count
        } else {
            return dataSourcePeople.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if isFiltering{
            cell.textLabel?.text = filteredDataSource[indexPath.row].fullName()
            if channel!.people.contains(filteredDataSource[indexPath.row].id) {
                cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        } else {
            cell.textLabel?.text = dataSourcePeople[indexPath.row].fullName()
            if channel!.people.contains(dataSourcePeople[indexPath.row].id) {
                cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            if isFiltering{
                if cell.backgroundColor == #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) {
                    let filtered = channel!.people.filter{ $0 != filteredDataSource[indexPath.row].id }
                    channel?.people = filtered
                    cell.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                } else {
                    channel?.people.append(filteredDataSource[indexPath.row].id)
                    cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                }
            } else {
                if cell.backgroundColor == #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) {
                    let filtered = channel!.people.filter{ $0 != dataSourcePeople[indexPath.row].id }
                    channel?.people = filtered
                    cell.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                } else {
                    channel?.people.append(dataSourcePeople[indexPath.row].id)
                    cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                }
            }
        }
    }
}

extension AddToChannelVC : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
