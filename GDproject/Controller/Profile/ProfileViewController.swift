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
    
    
    func fill(with user: User){
        self.facultyLabel.text = user.faculty ?? ""
        self.nameLabel.text = "\(user.initials.name) \(user.initials.optional ?? "")"
        self.surnameLabel.text = user.initials.surname
        self.profileImageView.image = #imageLiteral(resourceName: "kitten").roundedImage
        self.placeLabel.text = user.placeOfWork
    }
    
    var user: User = User(surname: "Богомазова", name: "Вероника", optional: "Львовна", emailName: "vbogomazova", id: 2, place: "📍Москва, Кочновский пр. 3", faculty: "Методист: Факультет Компьютерных наук")
    
    var basicInfo = BasicInfoController()
    var posts = NewsVC()
    
    var dataSourse: [Model.Posts]?{
        didSet{
            self.posts.dataSourse = dataSourse!
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Model.getPostsForUser(with: 42) { [weak self] (posts) in
            self?.dataSourse = posts
        }
        
        posts.viewController = self
        posts.type = .NONE
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        tableView.register(BasicInfoCell.self, forCellReuseIdentifier: basicInfoCellId)
        
        tableView.register(InfoCell.self, forCellReuseIdentifier: infoCellId)
        
        posts.viewController = self
        
        fill(with: user)
        tableView.delegate = posts
        tableView.dataSource = posts
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUpNavigarionBar()
    }
    
    func setUpNavigarionBar(){
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = user.login
        let uibarbutton = UIBarButtonItem(title: "More", style: .plain, target: self, action: #selector(showInformation))
        navigationItem.rightBarButtonItems = [uibarbutton]
        navigationItem.largeTitleDisplayMode = .always
    }
    
    
    let copyLink: UIAlertAction = {
        let b = UIAlertAction(title: "Copy link", style: .default)
        return b
    }()
    
    @objc func showInformation(){
        
        // drafts
        // saved
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Edit profile", style: .default)
        let settingsAction = UIAlertAction(title: "Setting", style: .default)
        { [weak self] (_) in
            
           let vc = self?.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutAction = UIAlertAction(title: "Log out", style: .destructive)
        {
            (_) in
            DataStorage.standard.setIsLoggedIn(value: false)
        }
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(settingsAction)
        optionMenu.addAction(copyLink)
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
