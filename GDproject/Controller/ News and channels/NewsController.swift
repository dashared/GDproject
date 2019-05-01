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
}

protocol UpdateableWithUser: class {
    var user: Model.Users? { get set }
}
// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UIViewController, UISearchControllerDelegate, UpdateableWithChannel
{
    var changedChannelName: ((String)->())?
    
    @IBOutlet weak var tableView: UITableView!
    
    var channel: Model.Channels?
    var anonymousChannel: (users: [Int: Model.Users], posts: [Model.Posts])?
    
    // MARK: - Output -
    var onSelectChannel: (() -> Void)?
    
    var searchController = UISearchController(searchResultsController: nil)

    var news = NewsVC()
    var type: HeaderType? = .NEWS
    
    var refreshContr =  UIRefreshControl()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Loading ..."
        tableView.refreshControl = refreshContr
        // Configure Refresh Control
        refreshContr.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)
    
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        // setUpSearchContr()
        
        news.viewController = self
        news.type = type == .NEWS ? .NEWS : type!
        
        setUpNavigationItemsforPosts()

        //setUpBanner()
    }
    
    func setUpSearchContr(){
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.placeholder  = "Search anything"
    }
    
    @objc func refreshPostsData( _ ff: UIRefreshControl){
        decideWhatChannelDisplay()
    }
    
    deinit {
        print("news clear")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
        // TODO:- display something if no posts are availiable
        
        decideWhatChannelDisplay()
        
        // tableView.reloadData()
    }
    
    func decideWhatChannelDisplay(){
        switch type! {
        case .NEWS, .NONE:
            if let channel = channel, let id = channel.id, id != -1 {
                
                Model.getChannel(with: id) { [weak self] in
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
}
