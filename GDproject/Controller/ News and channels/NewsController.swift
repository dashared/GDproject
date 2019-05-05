//
//  ViewController.swift
//  GDproject
//
//  Created by cstore on 13/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints
import Cartography

protocol UpdateableWithChannel: class {
    var channel: Model.Channels? { get set }
    func updateChannel(on channel: Model.Channels)
}

protocol UpdateableWithUser: class {
    var user: Model.Users? { get set }
}
// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UIViewController, UISearchControllerDelegate, UpdateableWithChannel, UISearchResultsUpdating
{
    func updateChannel(on channel: Model.Channels) {
        self.channel = channel
        news.currChannel = channel
        decideWhatChannelDisplay()
    }
    
    var changedChannelName: ((String)->())?
    
    @IBOutlet weak var tableView: UITableView!
    
    var channel: Model.Channels?
    var anonymousChannel: (users: [Int: Model.Users], posts: [Model.Posts])?
    
    // MARK: - Output -
    var onSelectChannel: (() -> Void)?
    
    var searchController: UISearchController?

    var news = NewsVC()
    var type: HeaderType? = .NEWS
    
    var refreshContr =  UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let updater = TagsSuggestionController()
        updater.delegate = self
        searchController = UISearchController(searchResultsController: updater)
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Loading ..."
        tableView.refreshControl = refreshContr
        // Configure Refresh Control
        refreshContr.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)
    
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setUpSearchContr()
        
        // navigationItem.
        news.viewController = self
        news.type = type == .NEWS ? .NEWS : type!
        news.currChannel = channel
        
        setUpNavigationItemsforPosts()
    }
    
    func setUpSearchContr(){
        searchController?.delegate = self
        searchController?.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController?.searchResultsUpdater = self
        searchController?.searchBar.placeholder  = "Search tags"
    }
    
    @objc func refreshPostsData( _ ff: UIRefreshControl){
        decideWhatChannelDisplay()
    }
    
    deinit {
        print("news clear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController?.isActive = false
        // TODO:- display something if no posts are availiable
        
        decideWhatChannelDisplay()
        
        // tableView.reloadData()
    }
    
    func decideWhatChannelDisplay(){
        
        switch type! {
        case .NEWS, .NONE:
            if let channel = channel, let id = channel.id, id != -1 {
                
                Model.getAnonymousChannel(by: channel) { [weak self] in
                    self?.news.dataSourse = $0.posts
                    self?.news.dictionary = $0.users
                    self?.refreshContr.endRefreshing()
                    self?.changedChannelName?(channel.name)
                }
                
            } else {
                Model.getLast { [weak self] in
                    self?.news.dataSourse = $0.posts
                    self?.news.dictionary = $0.users
                    self?.refreshContr.endRefreshing()
                    self?.changedChannelName?("General")
                }
            }
        default:
            if let anonChannel = anonymousChannel {
                news.dataSourse = anonChannel.posts
                news.dictionary = anonChannel.users
                changedChannelName?("Anonymous")
            }
        }
        
    }
    
    func setUpNavigationItemsforPosts(){
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
    }
    
    func updateSearchResults(for searchController: UISearchController)
    {
        let filteredData = CompletionTree.getCompletion(tree: Model.hashTagTree!, word: searchController.searchBar.text?.lowercased() ?? "")

        // Apply the filtered results to the search results table.
        if let resultsController = searchController.searchResultsController as? TagsSuggestionController {
            resultsController.suggestions = filteredData
            resultsController.tableView.reloadData()
        }
    }
    
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false;
    }
    
    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchResultsController?.view.isHidden = false;
    }
    
    func didDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.text = ""
    }
}
