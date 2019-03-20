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
protocol NewPostDelegate {
    func addPost(post: Post)
}
protocol UpdateableWithUser: class {
    var user: Model.Users? { get set }
}
// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UIViewController, UISearchControllerDelegate, NewPostDelegate, UpdateableWithChannel, DataDelegate
{

    var changedChannelName: ((String)->())?
    
    func passData(for row: Int, channel: Model.Channels) {
        if channel.id == -1{
            self.channel = nil
        } else {
            self.channel = channel
        }
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    var dictionary: [Int: Model.Users]?  {
        didSet {

            var newPosts: [Model.Posts] = []
            
            posts!.forEach({ (post) in
                
                newPosts.append(Model.Posts(body: post.body, authorId: post.authorId, id: post.id, user: dictionary![post.authorId]!, date: post.updated, tags: post.tags))
                
                post.tags.forEach { Model.Channels.fullTags.insert($0) }
                
            })
            
            
            news.dataSourse = newPosts
            tableView.reloadData()
        }
    }
    
    var posts: [Model.Posts]? {
        didSet{
            
        }
    }
    
    var channel: Model.Channels?
    
    // MARK: - Output -
    var onSelectChannel: (() -> Void)?

    func addPost(post: Post) {
        //news.dataSourse.insert(post, at: 0)
    }
    
    var searchController = UISearchController(searchResultsController: nil)

    var news = NewsVC()
    
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
        news.type = .NEWS
        
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
    
    let label : UILabel = {
        let label = UILabel()
        label.text = "No posts to display yet!"
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = false
        // TODO:- display something if no posts are availiable
        
        decideWhatChannelDisplay()
        
        // tableView.reloadData()
    }
    
    func decideWhatChannelDisplay(){
        if let channel = channel, let id = channel.id {
            
            Model.getChannel(with: id) { [weak self] in
                self?.posts = $0.posts
                self?.dictionary = $0.users
                self?.refreshContr.endRefreshing()
                self?.changedChannelName?(channel.name)
            }
            
        } else {
            
            Model.getLast { [weak self] in
                self?.posts = $0.posts
                self?.dictionary = $0.users
                self?.refreshContr.endRefreshing()
                self?.changedChannelName?("General")
            }
        }
    }
    
    func setUpNavigationItemsforPosts(){
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
    }
    
    
    // for animating the banner
    var topConstraint: NSLayoutConstraint?
    
    let bannerView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.layer.cornerRadius = 25.0
        view.clipsToBounds = true
        return view
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    // MARK:- banner
    private func setUpBanner()
    {
        view.addSubview(bannerView)
        bannerView.addSubview(statusLabel)
        statusLabel.edgesToSuperview()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
        
        bannerView.addGestureRecognizer(tap)
        topConstraint = NSLayoutConstraint(item: bannerView, attribute: .top, relatedBy: .equal, toItem: view.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: -300)
        view.addConstraint(topConstraint!)
        
        bannerView.edgesToSuperview(excluding: [.bottom, .top, .left], insets: .right(20), usingSafeArea: true)
        bannerView.height(50)
        bannerView.width(50)
    }
    
    // when table is scrolling no deletion is availiable
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        let indexPath = IndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//        isBannerVisible = false
//        changeConstraint(isVisible: false)
    }
    
    // animation for banner
    func changeConstraint(isVisible: Bool){
        topConstraint?.constant =  isVisible ? 50 : -300
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }) { (completed) in
            
        }
    }
    
    var isBannerVisible: Bool = false
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset.y)
        if scrollView.contentOffset.y >= 50 && !isBannerVisible{
            isBannerVisible = true
            changeConstraint(isVisible: true)
        }
        
        if isBannerVisible && scrollView.contentOffset.y == 0{
            isBannerVisible = false
            changeConstraint(isVisible: false)
        }
    }
}
