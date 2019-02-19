//
//  ChannelController.swift
//  GDproject
//
//  Created by cstore on 19/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class ChannelController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UISearchBarDelegate
{
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource: [String] = []
    
    var people: [String] = ["Ann", "Ilya", "Kostya"]
    var fullPeople: [String] = ["Other Ann", "Other Ilya", "Other Kostya", "Pasha", "Valera"]
    var tags: [String] = ["# foo", "# bar", "# kek"]
    var fullTags: [String] = ["# happy", "# sad", "# meme", "# shershakov", "# pupsik"]
    
    @IBOutlet weak var viewww: UIView!
    
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        dataSource = people
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: itemCellId)
        tableView.reloadData()
        textField.delegate = self
        searchBar.delegate = self
        searchBar.selectedScopeButtonIndex = 0
        navigationItem.title = "Title"
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: itemCellId, for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
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
    
    //change
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        navigationItem.title = textField.text
        return true
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
            dataSource = searchBar.selectedScopeButtonIndex == 0 ? people : tags
            flag = searchBar.selectedScopeButtonIndex == 0 ? false : true
            tableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        dataSource = searchBar.selectedScopeButtonIndex == 0 ? people : tags
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
