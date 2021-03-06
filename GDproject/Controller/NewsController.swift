//
//  ViewController.swift
//  GDproject
//
//  Created by cstore on 13/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

// MARK:- Controller with posts and channels availiable.
// Search is availiable within every table (posts and channels). Has button-functionality for boths post and chnnels
class NewsController: UIViewController
{

    @IBOutlet weak var tableView: UITableView!
    
    var searchController = UISearchController(searchResultsController: nil)
    
    var dataSourse: [Post] = [Post(dataArray: [.text("Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise en page avant impression. Le Lorem Ipsum est le faux texte standard de l'imprimerie depuis les années 1500, quand un imprimeur anonyme assembla ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte. Il n'a pas fait que survivre cinq siècles, mais s'est aussi adapté à la bureautique informatique, sans que son contenu n'en soit modifié. Il a été popularisé dans les années 1960 grâce à la vente de feuilles Letraset contenant des passages du Lorem Ipsum, et, plus récemment, par son inclusion dans des applications de mise en page de texte, comme Aldus PageMaker. \n On sait depuis longtemps que travailler avec du texte lisible et contenant du sens est source de distractions, et empêche de se concentrer sur la mise en page elle-même. L'avantage du Lorem Ipsum sur un texte générique comme 'Du texte. Du texte. Du texte.' est qu'il possède une distribution de lettres plus ou moins normale, et en tout cas comparable avec celle du français standard. De nombreuses suites logicielles de mise en page ou éditeurs de sites Web ont fait du Lorem Ipsum leur faux texte par défaut, et une recherche pour 'Lorem Ipsum' vous conduira vers de nombreux sites qui n'en sont encore qu'à leur phase de construction. Plusieurs versions sont apparues avec le temps, parfois par accident, souvent intentionnellement (histoire d'y rajouter de petits clins d'oeil, voire des phrases embarassantes).")], from: User(name: "vbogomazova", id: 2, fullName: "Богомазова Вероника Львовна"), date: "14.02.19 в 12:05")]
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.register(HeaderNewsChannels.self, forCellReuseIdentifier: headerNewsChannelsVC)
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        setUpNavigationItemsforPosts()
        searchController.searchBar.placeholder  = "Search anything"
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        setUpBanner()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setUpNavigationItemsforPosts(){
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(self.writePost(_:)))]
    }
    
    func setUpNavigationItemsForChannels(){
        navigationItem.title = "Channels"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addChannel))]
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
    
    @objc func addChannel(){
        print("Add channel")
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

// MARK:- tableView delegate
extension NewsController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = storyboard!.instantiateViewController(withIdentifier: fullPostControllerId) as! FullPostController

        vc.post = dataSourse[indexPath.row]
        navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK:- tableView dataSourse
extension NewsController: UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellId, for: indexPath) as! PostViewCell
        
        cell.fill(with: dataSourse[indexPath.row].dataArray, false)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 46.0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: headerNewsChannelsVC) as! HeaderNewsChannels
        cell.vc = self
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46.0))
        view.addSubview(cell)
        cell.edgesToSuperview()
        
        return view
    }
    
    
}
