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
    
    let basicInfo = BasicInfoController()
    let posts = NewsVC()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        posts.type = .NONE
        
        posts.dataSourse = [Post(dataArray: [.text("Le Lorem Ipsum est simplement du faux texte employé dans la composition et la mise en page avant impression. Le Lorem Ipsum est le faux texte standard de l'imprimerie depuis les années 1500, quand un imprimeur anonyme assembla ensemble des morceaux de texte pour réaliser un livre spécimen de polices de texte. comme Aldus PageMaker. est qu'il possède une distribution de lettres plus ou moins normale, et en tout cas comparable avec celle du français standard. De nombreuses suites logicielles de mise en page ou éditeurs de sites Web ont fait du Lorem Ipsum leur faux texte par défaut, et une recherche pour 'Lorem Ipsum' vous conduira vers de nombreux sites qui n'en sont encore qu'à leur phase de construction. Plusieurs versions sont apparues avec le temps, parfois par accident, souvent intentionnellement (histoire d'y rajouter de petits clins d'oeil, voire des phrases embarassantes).")]), Post(dataArray: [.text("Il n'a pas fait que survivre cinq siècles, mais s'est aussi adapté à la bureautique informatique, sans que son contenu n'en soit modifié. Il a été popularisé dans les années 1960 grâce à la vente de feuilles Letraset contenant des passages du Lorem Ipsum, et, plus récemment, par son inclusion dans des applications de mise en page de texte, comme Aldus PageMaker. .")])]
        
       // basicInfo.dataSourse =
        
        posts.viewController = self
        
        tableView.register(HeaderNewsChannels.self, forCellReuseIdentifier: headerNewsChannelsVC)
        
        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        tableView.register(BasicInfoCell.self, forCellReuseIdentifier: basicInfoCellId)
        
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
        let settingsAction = UIAlertAction(title: "Settings", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let shareAction = UIAlertAction(title: "Share", style: .default)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(settingsAction)
        optionMenu.addAction(copyLink)
        optionMenu.addAction(shareAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
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
