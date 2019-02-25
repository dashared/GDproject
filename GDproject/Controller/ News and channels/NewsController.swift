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
    var channel: Channel? { get set }
}
protocol NewPostDelegate {
    func addPost(post: Post)
}

// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UITableViewController, UISearchControllerDelegate, NewPostDelegate, UpdateableWithChannel, DataDelegate
{
    func passData(for row: Int, channel: Channel) {
        self.channel = channel
    }
    
    var dictionary: [Int: Model.Users]?  {
        didSet{

            var newPosts: [Model.Posts] = []
            
            channel?.posts.forEach({ (post) in
                newPosts.append(Model.Posts(body: post.body, authorId: post.authorId, id: post.id, user: dictionary![post.authorId]!))
            })
            
            
            news.dataSourse = newPosts
            tableView.reloadData()
        }
    }
    
    var channel: Channel?{
        didSet{
            let hh = channel?.posts.map({ (post) -> Int in
                post.authorId
            })
            
            navigationItem.title = channel?.title ?? ""
            Model.getUsers(for: hh ?? []) { [weak self] (dict) in
                self?.dictionary = dict
                self?.refreshContr?.endRefreshing()
            }
        }
    }
    
    // MARK: - Output -
    var onSelectChannel: (() -> Void)?

    func addPost(post: Post) {
        //news.dataSourse.insert(post, at: 0)
    }
    
    var searchController = UISearchController(searchResultsController: nil)

    var news = NewsVC()
    
    var refreshContr: UIRefreshControl? = {
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(refreshPostsData(_:)), for: .valueChanged)
        return rc
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationItem.title = "Loading ..."
        tableView.refreshControl = refreshContr
        // Configure Refresh Control
        
        Model.getLast { [weak self] (channel) in
            self?.channel = channel
        }
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        setUpSearchContr()
        
        news.viewController = self
        news.type = .NONE
        
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
        if ff.isRefreshing {
            Model.getLast { [weak self] (channel) in
                self?.channel = channel
                self?.refreshContr?.endRefreshing()
            }
        }
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
        
        refreshContr?.beginRefreshing()
        
        // tableView.reloadData()
    }
    
    func setUpNavigationItemsforPosts(){
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.writePost(_:))),UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.showChannels(_:)))
        ]
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
    }
    
    // MARK:- attempt with coordinator
    @objc func showChannels(_ barItem: UIBarButtonItem){
        let vc = UIStoryboard.makeChannelsListController()
        vc.myProtocol = self
        vc.displayingChannel = channel
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func writePost(_ barItem: UIBarButtonItem)
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: vc, action: #selector(vc.newPost))
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: vc, action: #selector(vc.closeView))
        
        vc.myProtocol = self
        
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.moveIn
        transition.subtype = CATransitionSubtype.fromTop
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
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
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
