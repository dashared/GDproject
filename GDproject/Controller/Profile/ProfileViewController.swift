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
    
    @IBAction func sendMessage(_ sender: UIButton)
    {
        if let userId = idProfile
        {
            let createdDialog = Model.Dialog.userChat(Model.UserChat(user: userId))
            let vc = DialogViewController()
            vc.users = Model.Channels.fullPeopleDict
            vc.dialog = createdDialog
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    var onChannelsListToAddAPerson: ((Model.Users)->())?
    
    var protoDictionary: [String: UIImage] = ["135213": #imageLiteral(resourceName: "9"), "135288": #imageLiteral(resourceName: "5051"), "22723" : #imageLiteral(resourceName: "69"), "135083": #imageLiteral(resourceName: "42")]
    
    func fill(with user: Model.Users)
    {
        self.facultyLabel.text =  user.faculty.name
        self.nameLabel.text = "\(user.firstName) \(user.middleName)"
        self.surnameLabel.text = "\(user.lastName)"
        self.profileImageView.image = protoDictionary[user.faculty.campusCode]?.roundedImage
        self.placeLabel.text = "📍\(user.faculty.address)"
        if user.id == DataStorage.standard.getUserId() {
            newMessageButton.isHidden  = true
        } else {
            newMessageButton.isHidden  = false
        }
    }
    
    var user: Model.Users? {
        didSet {
            if let user = user {
                self.fill(with: user)
                navigationItem.title = "\(user.firstName) \(user.lastName)"
            } else if let id = idProfile {
                Model.getUsers(for: [id]) { [unowned self ] in
                    self.user = $0[id]
                }
            }
        }
    }
    
    var channel: Model.Channels? {
        didSet {
            self.update()
        }
    }
    
    func update()
    {
        Model.getAnonymousChannel(by: channel!) { [unowned self] in
            self.posts.dataSourse = $0.posts
            self.posts.dictionary = $0.users
            self.user = $0.users[self.idProfile!]
        }
    }
    
    var basicInfo = BasicInfoController()
    var posts = NewsVC()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if idProfile == nil {
            idProfile = DataStorage.standard.getUserId()
        }

        posts.viewController = self
        posts.type = .NONE
        posts.currChannel = channel
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        tableView.register(BasicInfoCell.self, forCellReuseIdentifier: basicInfoCellId)
    
        tableView.register(InfoCell.self, forCellReuseIdentifier: infoCellId)
        
        posts.viewController = self
        
        tableView.delegate = posts
        tableView.dataSource = posts
        tableView.reloadData()
    }
    
    var idProfile: Int? {
        didSet {
            channel = Model.Channels(people: [idProfile!], name: "", id: 0, tags: [])
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.tabBar.isHidden = false
        
        if idProfile == nil {
            idProfile = DataStorage.standard.getUserId()
        }
        user = Model.Channels.fullPeopleDict[idProfile!]
        
        update()
        
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
