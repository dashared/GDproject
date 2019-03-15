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
    
    var fullTags: [String] = Array(Model.Channels.fullTags)
    
    var dataSourcePeople: [Model.Users] = []
    
    var dataSourceTags: [String] = []
    
    var activeDataSource: ActiveTable = .people
    
    @IBOutlet weak var viewww: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSourceTags = channel!.tags
        setUpController()
        tableView.reloadData()
    }
    
    var reloadtable: Bool = false {
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Model.getUsers(for: channel!.people) { [weak self] (people) in
            self?.dataSourcePeople = Array(people.values)
            self?.reloadtable = true
        }
    }
    
    // TODO: update channel
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let _ = channel?.id {        print("update")
            Model.updateChannel(with: channel!)
        } else {                        print("create")
            Model.createChannel(with: channel!)
        }
    }
    
    func setUpController(){
        
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
    
    
    
    @objc func changedText(_ textField: UITextField){
        navigationItem.title = textField.text
        channel?.name = textField.text!
        // myProtocol?.passData(for: index!, channel: channel!)
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
        if searchBar.isFirstResponder, let cell = tableView.cellForRow(at: indexPath)
        {
                if cell.accessoryType == .none{
                    switch searchBar.selectedScopeButtonIndex{
                    case 0:
                        channel?.people.append(dataSourcePeople[indexPath.row].id)
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
                        let filtered = channel!.people.filter{ $0 != Model.Channels.fullPeople[indexPath.row].id }
                        channel?.people = filtered
                    case 1:
                        let filtered = channel!.tags.filter{
                            !fullTags[indexPath.row].contains($0)
                        }
                        channel?.tags = filtered
                    default:
                        break
                    }
                }
        }
        else
        {
            switch activeDataSource{
            case .people:
                channel?.people.remove(at: indexPath.row)
            case .tags:
                channel?.tags.remove(at: indexPath.row)
            }
            
            tableView.beginUpdates()
            switch activeDataSource{
            case .people:
                dataSourcePeople.remove(at: indexPath.row)
            case .tags:
                dataSourceTags.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .none)
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
        
        cell.textLabel?.text = activeDataSource == .people ? "\(dataSourcePeople[indexPath.row].firstName) \(dataSourcePeople[indexPath.row].middleName) \(dataSourcePeople[indexPath.row].lastName)" : dataSourceTags[indexPath.row]
        cell.selectionStyle = .none
        
        if activeDataSource == .tags && channel!.tags.contains(dataSourceTags[indexPath.row]) ||
            activeDataSource == .people && channel!.people.contains(dataSourcePeople[indexPath.row].id)
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
                dataSourcePeople = Model.Channels.fullPeople
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
            dataSourcePeople = Model.Channels.fullPeople.filter {
                let fullName = "\($0.firstName) \($0.middleName) \($0.lastName)"
                return fullName.lowercased().contains(text.lowercased())
            }
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
        activeDataSource = searchBar.selectedScopeButtonIndex == 0 ? .people : .tags
        if searchBar.isFirstResponder {
            switch activeDataSource{
            case .people :
                dataSourcePeople = Model.Channels.fullPeople
                dataSourceTags = []
            case .tags:
                dataSourceTags = fullTags
                dataSourcePeople = []
            }
            if (!(searchBar.text?.isEmpty ?? true))
            {
                filterTableView(ind: selectedScope, text: searchBar.text!)
            }
            tableView.reloadData()
        } else if !(searchBar.isFirstResponder){
            switch activeDataSource{
            case .people :
                dataSourcePeople = channel!.people.map({ (item) -> Model.Users in
                    Model.Channels.fullPeopleDict[item]!
                })
                dataSourceTags = []
            case .tags:
                dataSourceTags = channel!.tags
                dataSourcePeople = []
            }
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        switch activeDataSource{
        case .people :
            dataSourcePeople = channel!.people.map({ (item) -> Model.Users in
                Model.Channels.fullPeopleDict[item]!
            })
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
            dataSourcePeople = Model.Channels.fullPeople
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
