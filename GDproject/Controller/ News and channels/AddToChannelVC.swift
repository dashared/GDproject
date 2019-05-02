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
    var dataSourse: DataSourse = .people
    weak var update: UpdatableChannel?
    
    // data sources for people and hashtags
    var dataSourcePeople: [Model.Users] = Model.Channels.fullPeople
    var fullTags: [String] = CompletionTree.getCompletion(tree: Model.hashTagTree!, word: "")
    
    
    var reloadtable: Bool = false {
        didSet{
            tableView.reloadData()
        }
    }

    let searchC = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationItem.searchController = searchC
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.hidesSearchBarWhenScrolling = false
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        update?.updateChannel(with: channel!)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataSourse {
        case .people:
            return dataSourcePeople.count
        default:
            return fullTags.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        switch dataSourse {
        case .people:
            cell.textLabel?.text = dataSourcePeople[indexPath.row].fullName()
            if channel!.people.contains(dataSourcePeople[indexPath.row].id) {
                cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
            } else {
                cell.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        default:
            cell.textLabel?.text = "# \(fullTags[indexPath.row])"
            if channel!.tags.contains(fullTags[indexPath.row]) {
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
            switch dataSourse {
            case .people:
                if cell.backgroundColor == #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) {
                    let filtered = channel!.people.filter{ $0 != dataSourcePeople[indexPath.row].id }
                    channel?.people = filtered
                    cell.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                } else {
                    channel?.people.append(dataSourcePeople[indexPath.row].id)
                    cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                }
            default: //tags
                if cell.backgroundColor == #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1) {
                    let filtered = channel!.tags.filter{
                        !fullTags[indexPath.row].contains($0)
                    }
                    channel?.tags = filtered
                    cell.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
                } else {
                    channel?.tags.append(fullTags[indexPath.row])
                    cell.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
                }
            }
        }
    }

}
