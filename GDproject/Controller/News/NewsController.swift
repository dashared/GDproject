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

// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UIViewController, UISearchControllerDelegate, UITableViewDelegate, UITableViewDataSource
{
    
    
    var array = ["Faculty 1", "Faculty 2","Faculty 3","Faculty 4","Faculty 5","Faculty 6","Faculty 7","Faculty 8","Faculty 9","Faculty 10","Faculty 11","Faculty 12","Faculty 13","Faculty 14","Faculty 15","Faculty 16","Faculty 17","Faculty 18"]

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var dataSourse: [Post] = [Post(dataArray: [.text("Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise en page avant impression. Le Lorem Ipsum est le faux texte standard de l'imprimerie depuis les années 1500, quand un imprimeur anonyme assembla ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte. Il n'a pas fait que survivre cinq siècles, mais s'est aussi adapté à la bureautique informatique, sans que son contenu n'en soit modifié. Il a été popularisé dans les années 1960 grâce à la vente de feuilles Letraset contenant des passages du Lorem Ipsum, et, plus récemment, par son inclusion dans des applications de mise en page de texte, comme Aldus PageMaker. \n On sait depuis longtemps que travailler avec du texte lisible et contenant du sens est source de distractions, et empêche de se concentrer sur la mise en page elle-même. L'avantage du Lorem Ipsum sur un texte générique comme 'Du texte. Du texte. Du texte.' est qu'il possède une distribution de lettres plus ou moins normale, et en tout cas comparable avec celle du français standard. De nombreuses suites logicielles de mise en page ou éditeurs de sites Web ont fait du Lorem Ipsum leur faux texte par défaut, et une recherche pour 'Lorem Ipsum' vous conduira vers de nombreux sites qui n'en sont encore qu'à leur phase de construction. Plusieurs versions sont apparues avec le temps, parfois par accident, souvent intentionnellement (histoire d'y rajouter de petits clins d'oeil, voire des phrases embarassantes).")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05")]
    
    var news = NewsVC()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        news.dataSourse = dataSourse
        news.viewController = self
        
        
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
        
        news.type = .NEWS
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("hello")
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setUpNavigationItemsforPosts(){
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.writePost(_:)))]
        tableView.delegate = news
        tableView.dataSource = news
        tableView.reloadData()
    }
    
    
    
    @objc func writePost(_ barItem: UIBarButtonItem)
    {
        let vc = storyboard?.instantiateViewController(withIdentifier: "NewPostViewController") as! NewPostViewController
        
        vc.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .plain, target: vc, action: #selector(vc.newPost))
        vc.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: vc, action: #selector(vc.closeView))
        
        vc.parentVC = self
        
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
