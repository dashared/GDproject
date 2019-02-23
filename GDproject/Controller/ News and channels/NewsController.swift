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
class NewsController: UITableViewController, UISearchControllerDelegate, NewPostDelegate, UpdateableWithChannel
{
    var channel: Channel?{
        didSet{
            news.dataSourse = channel?.posts ?? []
            navigationItem.title = channel?.title ?? ""
        }
    }
    
    // MARK: - Output -
    var onSelectChannel: (() -> Void)?

    func addPost(post: Post) {
        news.dataSourse.insert(post, at: 0)
    }
    
    var array = ["Faculty 1", "Faculty 2","Faculty 3","Faculty 4","Faculty 5","Faculty 6","Faculty 7","Faculty 8","Faculty 9","Faculty 10","Faculty 11","Faculty 12","Faculty 13","Faculty 14","Faculty 15","Faculty 16","Faculty 17","Faculty 18"]

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        cell.textLabel?.text = array[indexPath.row]
        return cell
    }

    func presentSearchController(_ searchController: UISearchController) {
        print("here")
        setUpTableView()
        displayTableView() //setup
        // this is 0.3
        animateTable(some: true)
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        dismissTable()
    }

    //@IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil)

    
    var news = NewsVC()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        //view.backgroundColor = .white
        channel = ChannelListController.dataSource[0]
        
        view.addSubview(label)
        //label.horizontalToSuperview(insets: .left(30) + .right(30))
        //label.verticalToSuperview()
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        news.dataSourse = channel!.posts
        news.viewController = self
        
        
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
        
        news.type = .NONE
        
        setUpNavigationItemsforPosts()
        searchController.searchBar.placeholder  = "Search anything"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setUpBanner()
    }
    
    
    var facultyTableView = UITableView()
    
    func setUpTableView()
    {
        facultyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        facultyTableView.delegate = self
        facultyTableView.dataSource = self
        let screenSize: CGRect = UIScreen.main.bounds
        
        let screenWidth = screenSize.width
        let screenHeight = screenSize.height
        facultyTableView.frame = CGRect(x: 0, y: 0, width: Int(screenWidth), height: Int(screenHeight))
    }
    
    func displayTableView(){
        
        // the most important line
        facultyTableView.translatesAutoresizingMaskIntoConstraints = false
        facultyTableView.backgroundColor = UIColor(white: 1, alpha: 1)
        view.addSubview(facultyTableView)
        
        facultyTableView.isHidden = true
        
        // now
        constrain(facultyTableView, view){
            tableView, view in
            
            tableView.top == view.safeAreaLayoutGuide.top
            tableView.left == view.left
            tableView.right == view.right
            tableView.bottom == view.safeAreaLayoutGuide.bottom
        }
        
    }
    
    // animation of the table cells
    func animateTable(some: Bool){
        self.facultyTableView.reloadData()
        self.facultyTableView.isHidden = false
    }
    
    func dismissTable() {
        self.facultyTableView.isHidden = true
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
        print("hello")
        navigationController?.navigationBar.prefersLargeTitles = true
        if channel!.posts.isEmpty {
            //tableView.isHidden = true
            label.isHidden = false
        } else {
            label.isHidden = true
            tableView.isHidden = false
            tableView.reloadData()
        }
    }
    
    func setUpNavigationItemsforPosts(){
        navigationItem.rightBarButtonItems = [
                                              UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.writePost(_:))),
                                            UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(self.showChannels(_:)))]
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
    }
    
    // MARK:- attempt with coordinator
    @objc func showChannels(_ barItem: UIBarButtonItem){
        onSelectChannel?()
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
