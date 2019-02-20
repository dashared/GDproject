//
//  ChannelController.swift
//  GDproject
//
//  Created by cstore on 19/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol DataDelegate {
    func passData(for row: Int, channel: Channel)
}

class ChannelController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var index: Int?
    var channel: Channel?
    var myProtocol: DataDelegate?
    
    var dataSource: [String] = []
    
    var fullPeople: [String] = ["Other Ann", "Other Ilya", "Other Kostya", "Pasha", "Valera"]
    
    var fullTags: [String] = ["# happy", "# sad", "# meme", "# shershakov", "# pupsik"]
    
    @IBOutlet weak var viewww: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dataSource = channel!.people
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellId)
        tableView.reloadData()
        textField.delegate = self
        searchBar.delegate = self
        searchBar.selectedScopeButtonIndex = 0
        navigationItem.title = channel?.title
        textField.placeholder = channel?.title
        textField.addTarget(self, action: #selector(changedText(_:)), for: .editingChanged)
    }
    
    @objc func changedText(_ textField: UITextField){
        navigationItem.title = textField.text
        channel?.title = textField.text!
        myProtocol?.passData(for: index!, channel: channel!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            if let cell = tableView.cellForRow(at: indexPath)
            {
                
                if cell.accessoryType == .none{
                    switch searchBar.selectedScopeButtonIndex{
                    case 0:
                        channel?.people.append(dataSource[indexPath.row])
                    case 1:
                        channel?.hashtags.append(dataSource[indexPath.row])
                    default:
                        break
                    }
                    
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                    
                    switch searchBar.selectedScopeButtonIndex{
                    case 0:
                        channel?.people = channel!.people.filter({ (s) -> Bool in
                            !fullPeople[indexPath.row].contains(s)
                        })
                    // TODO: dataPass
                    case 1:
                        channel?.hashtags = channel!.people.filter({ (s) -> Bool in
                            !fullTags[indexPath.row].contains(s)
                        })
                    // TODO: dataPass
                    default:
                        break
                    }
                }
            }
        } else
        {
            tableView.beginUpdates()
            dataSource.remove(at: indexPath.row)
            switch searchBar.selectedScopeButtonIndex{
            case 0:
                channel?.people.remove(at: indexPath.row)
            // TODO: dataPass
            case 1:
                channel?.hashtags.remove(at: indexPath.row)
            // TODO: dataPass
            default:
                break
            }
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        cell.selectionStyle = .none
        
        if channel!.hashtags.contains(dataSource[indexPath.row]) || channel!.people.contains(dataSource[indexPath.row])
        {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
    let searchBar: UISearchBar = {
        let searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        searchBar.showsScopeBar = true
        searchBar.showsCancelButton = true
        searchBar.scopeButtonTitles = ["People", "Tags"]
        return searchBar
    }()
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 70))
        
        if flag {
            searchBar.selectedScopeButtonIndex = 1
        } else {
            searchBar.selectedScopeButtonIndex = 0
        }
        
        view.addSubview(searchBar)
        return view
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            dataSource = searchBar.selectedScopeButtonIndex == 0 ? fullPeople : fullTags
            tableView.reloadData()
        } else {
            filterTableView(ind: searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }
    
    func filterTableView(ind: Int, text: String){
        switch ind {
        case 0:
            dataSource = fullPeople.filter({ (s) -> Bool in
                s.lowercased().contains(text.lowercased())
            })
            tableView.reloadData()
        case 1:
            dataSource = fullTags.filter({ (s) -> Bool in
                s.lowercased().contains(text.lowercased())
            })
            tableView.reloadData()
        default:
            break
        }
    }
    
    var flag = false
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.isFirstResponder {
            dataSource = searchBar.selectedScopeButtonIndex == 0 ? fullPeople : fullTags
            flag = searchBar.selectedScopeButtonIndex == 0 ? false : true
            if (!(searchBar.text?.isEmpty ?? true))
            {
                filterTableView(ind: selectedScope, text: searchBar.text!)
            }
            tableView.reloadData()
        } else if !(searchBar.isFirstResponder){
            dataSource = searchBar.selectedScopeButtonIndex == 0 ? channel!.people : channel!.hashtags
            flag = searchBar.selectedScopeButtonIndex == 0 ? false : true
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        dataSource = searchBar.selectedScopeButtonIndex == 0 ? channel!.people : channel!.hashtags
        flag = searchBar.selectedScopeButtonIndex == 0 ? false : true
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        dataSource = searchBar.selectedScopeButtonIndex == 0 ? fullPeople : fullTags
        flag = searchBar.selectedScopeButtonIndex == 0 ? false : true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
