//
//  ChannelController.swift
//  GDproject
//
//  Created by cstore on 19/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol DataDelegate {
    func passData(for row: Int, channel: Model.Channels)
}

enum ActiveTable {
    case tags
    case people
}

class ChannelController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var index: Int?
    var channel: Model.Channels?
    var myProtocol: DataDelegate?
    
    var dataSourcePeople: [Int] = []
    var dataSourceTags: [String] = []
    
    var activeDataSource: ActiveTable = .people
    
    var fullPeople: [Int] = [5051,69]
    
    var fullTags: [String] = ["# happy", "# sad", "# meme", "# shershakov", "# pupsik"]
    
    @IBOutlet weak var viewww: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSourcePeople = channel!.people
        dataSourceTags = channel!.tags
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellId)
        tableView.reloadData()
        textField.delegate = self
        searchBar.delegate = self
        searchBar.selectedScopeButtonIndex = 0
        
        navigationItem.title = channel?.name
        textField.placeholder = channel?.name
        
        textField.addTarget(self, action: #selector(changedText(_:)), for: .editingChanged)
    }
    
    // TODO: update channel
    override func viewWillDisappear(_ animated: Bool) {
        if let _ = channel?.id {
            print("update")
            Model.updateChannel(with: channel!)
        } else {
            print("create")
            Model.createChannel(with: channel!)
        }
    }
    
    @objc func changedText(_ textField: UITextField){
        navigationItem.title = textField.text
        channel?.name = textField.text!
        myProtocol?.passData(for: index!, channel: channel!)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch activeDataSource {
        case .people:
            return dataSourcePeople.count
        case .tags:
            return dataSourceTags.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchBar.isFirstResponder {
            if let cell = tableView.cellForRow(at: indexPath)
            {
                
                if cell.accessoryType == .none{
                    switch searchBar.selectedScopeButtonIndex{
                    case 0:
                        channel?.people.append(dataSourcePeople[indexPath.row])
                        print("people = \(channel!.people)")
                    case 1:
                        channel?.tags.append(dataSourceTags[indexPath.row])
                        print("hashtags = \(channel!.tags)")
                    default:
                        break
                    }
                    
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                    
                    switch searchBar.selectedScopeButtonIndex{
                    case 0:
                        channel?.people = channel!.people.filter{ $0 == fullPeople[indexPath.row] }
                    // TODO: dataPass
                    case 1:
                        channel?.tags = channel!.tags.filter({ (s) -> Bool in
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
            switch activeDataSource{
            case .people:
                dataSourcePeople.remove(at: indexPath.row)
            case .tags:
                dataSourceTags.remove(at: indexPath.row)
            }
            switch searchBar.selectedScopeButtonIndex{
            case 0:
                channel?.people.remove(at: indexPath.row)
            // TODO: dataPass
            case 1:
                channel?.tags.remove(at: indexPath.row)
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
        
        cell.textLabel?.text = activeDataSource == .people ? String(dataSourcePeople[indexPath.row]) : dataSourceTags[indexPath.row]
        cell.selectionStyle = .none
        
        if activeDataSource == .tags && channel!.tags.contains(dataSourceTags[indexPath.row]) ||
            activeDataSource == .people && channel!.people.contains(dataSourcePeople[indexPath.row])
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
        
        if activeDataSource == .tags {
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
            switch activeDataSource {
            case .people:
                dataSourcePeople = fullPeople
            case .tags:
                dataSourceTags = fullTags
            }
            tableView.reloadData()
        } else {
            filterTableView(ind: searchBar.selectedScopeButtonIndex, text: searchText)
        }
    }
    
    func filterTableView(ind: Int, text: String){
        switch ind {
        case 0:
            dataSourcePeople = fullPeople.filter { if let numb = Int(text) { return $0 == numb } else {return false}}
            tableView.reloadData()
        case 1:
            dataSourceTags = fullTags.filter({ (s) -> Bool in
                s.lowercased().contains(text.lowercased())
            })
            tableView.reloadData()
        default:
            break
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if searchBar.isFirstResponder {
            switch activeDataSource{
            case .people :
                dataSourcePeople = fullPeople
                dataSourceTags = []
            case .tags:
                dataSourceTags = fullTags
                dataSourcePeople = []
            }
            print("\(searchBar.selectedScopeButtonIndex)")
            activeDataSource = searchBar.selectedScopeButtonIndex == 0 ? .people : .tags
            if (!(searchBar.text?.isEmpty ?? true))
            {
                filterTableView(ind: selectedScope, text: searchBar.text!)
            }
            tableView.reloadData()
        } else if !(searchBar.isFirstResponder){
            switch activeDataSource{
            case .people :
                dataSourcePeople = channel!.people
                dataSourceTags = []
            case .tags:
                dataSourceTags = channel!.tags
                dataSourcePeople = []
            }
            print(" not active \(searchBar.selectedScopeButtonIndex)")
            activeDataSource = searchBar.selectedScopeButtonIndex == 0 ? .people : .tags
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        switch activeDataSource{
        case .people :
            dataSourcePeople = channel!.people
            dataSourceTags = []
        case .tags:
            dataSourceTags = channel!.tags
            dataSourcePeople = []
        }
        activeDataSource = searchBar.selectedScopeButtonIndex == 0 ? .people : .tags
        tableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        switch activeDataSource{
        case .people :
            dataSourcePeople = fullPeople
            dataSourceTags = []
        case .tags:
            dataSourceTags = fullTags
            dataSourcePeople = []
        }
        activeDataSource = searchBar.selectedScopeButtonIndex == 0 ? .people : .tags
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
