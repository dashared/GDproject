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
    
    // MARK:- filter search controller
    
    var filteredDataSource = [Channel]()
    var myProtocol: DataDelegate?
    
    var generalChannel: Channel = Channel(title: "General", subtitle: "All posts", hashtags: ["All"], people: ["All"], posts: [])
    
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
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder  = "Search channel"
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
        ChannelListController.dataSource.insert(Channel(title: "Untitled", subtitle: "No", hashtags: [], people: [], posts: []), at: 0)
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
        Channel(title: "Title", subtitle: "subtitle", hashtags: ["# sad", "# happy"], people: ["Seva", "Andrey"], posts: [Post(dataArray: [.text("Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise en page avant impression. Le Lorem Ipsum est le faux texte standard.")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05")]),
        Channel(title: "Title2", subtitle: "subtitle2", hashtags: ["# studyhard", "# university"], people: ["Pasha", "Olya", "Andrey", "Ilya"], posts:
            [
            Post(dataArray: [.text("L'avantage du Lorem Ipsum sur un texte générique comme 'Du texte. Du texte. Du texte.' est qu'il possède une distribution de lettres plus ou moins normale.")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05"),
            Post(dataArray: [.text("par accident, souvent intentionnellement (histoire d'y rajouter de petits clins d'oeil, voire des phrases embarassantes).")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05")
            ]),
        Channel(title: "Title3", subtitle: "subtitle3", hashtags: ["# lol", "# meme", "# hehe"], people: ["Superman"], posts: [Post(dataArray: [.text("Ipsum est le faux texte standard de l'imprimerie depuis les années 1500, quand un imprimeur anonyme assembla ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte. Il n'a pas fait que survivre cinq siècles, mais s'est aussi adapté à la bureautique informatique, sans que son contenu n'en soit modifié.")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05")])
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if isFiltering {
            navigationController?.popViewController(animated: true)
            myProtocol?.passData(for: 0, channel: filteredDataSource[indexPath.row])
        } else {
            navigationController?.popViewController(animated: true)
            myProtocol?.passData(for: 0, channel: ChannelListController.dataSource[indexPath.row])
        }
    }
}


extension ChannelListController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
