//
//  ProfileViewController.swift
//  GDproject
//
//  Created by cstore on 15/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class ProfileViewController: UIViewController
{
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var profileView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var surnameLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var facultyLabel: UILabel!
    
    @IBOutlet weak var placeLabel: UILabel!
    
    @IBOutlet weak var newMessageButton: UIButton!
    
    var logOut: (()->())?
    
    var onSettings: (()->())?
    
    var onChannelsListToAddAPerson: ((Model.Users)->())?
    
    var protoDictionary: [Int: UIImage] = [9: #imageLiteral(resourceName: "9"), 5051: #imageLiteral(resourceName: "5051"), 69: #imageLiteral(resourceName: "69"), 42: #imageLiteral(resourceName: "42")]
    
    func fill(with user: Model.Users){
        self.facultyLabel.text = "Студент: Факультет Компьютерных Наук"
        self.nameLabel.text = "\(user.firstName) \(user.middleName)"
        self.surnameLabel.text = "\(user.lastName)"
        self.profileImageView.image = protoDictionary[user.id]?.roundedImage
        self.placeLabel.text = "📍Москва, Кочновский пр.3"
        if user.id == DataStorage.standard.getUserId() {
            newMessageButton.isHidden  = true
        } else {
            newMessageButton.isHidden  = false
        }
    }
    
    var user: Model.Users? {
        didSet {
            self.fill(with: user!)
            Model.getPostsForUser(with: user!.id) { [weak self] (posts) in
                self?.dataSourse = posts
            }
            navigationItem.title = "\(user!.firstName) \(user!.lastName)"
        }
    }
    
    var basicInfo = BasicInfoController()
    var posts = NewsVC()
    
    var dataSourse: [Model.Posts]?{
        didSet{
            
            var newPosts: [Model.Posts] = []
            
            dataSourse?.forEach({ (post) in
                newPosts.append(Model.Posts(body: post.body, authorId: post.authorId, id: post.id, user: user!, date: post.updated, tags: post.tags))
            })
            
            self.posts.dataSourse = newPosts
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("hell")
        posts.viewController = self
        posts.type = .NONE
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        tableView.register(BasicInfoCell.self, forCellReuseIdentifier: basicInfoCellId)
        
        tableView.register(InfoCell.self, forCellReuseIdentifier: infoCellId)
        
        posts.viewController = self
        
        tableView.delegate = posts
        tableView.dataSource = posts
        tableView.reloadData()
    }
    
    var idProfile: Int?
    
    override func viewWillAppear(_ animated: Bool) {
        
        if idProfile == nil {
            idProfile = DataStorage.standard.getUserId()
        }
        
        if let id = idProfile {
            if let user = Model.idUser[id] {
                self.user = user
            } else {
                Model.getUsers(for: [id]) { [weak self] (dic) in
                    self?.user = dic[id]
                }
            }
        }
        
        setUpNavigarionBar()
    }
    
    func setUpNavigarionBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        let uibarbutton = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(showInformation))
        navigationItem.rightBarButtonItems = [uibarbutton]
        navigationItem.largeTitleDisplayMode = .always
    }
    
    @objc func showInformation(){
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let channelAction = UIAlertAction(title: "Add to a channel", style: .default){
            [weak self] (_) in
            self?.onChannelsListToAddAPerson?(self!.user!)
        }
        
        let settingsAction = UIAlertAction(title: "Setting", style: .default)
        { [weak self] (_) in
           self?.onSettings?()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive)
        { [weak self]
            (_) in
            self?.logOut?()
        }
        
        optionMenu.addAction(channelAction)
        optionMenu.addAction(settingsAction)
        optionMenu.addAction(logoutAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    deinit {
        print("profile clear")
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        let index = sender.selectedSegmentIndex
        
        switch index {
        case 0:
            changeToPosts()
        case 1:
            changeToBasicInfo()
        default:
            break
        }
    }
    
    func changeToPosts(){
        tableView.delegate = posts
        tableView.dataSource = posts
        tableView.reloadData()
    }
    
    func changeToBasicInfo(){
        tableView.delegate = basicInfo
        tableView.dataSource = basicInfo
        tableView.reloadData()
    }
}
