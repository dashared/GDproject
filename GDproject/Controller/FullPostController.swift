//
//  FullPostViewController.swift
//  GDproject
//
//  Created by cstore on 13/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import TinyConstraints

class FullPostController: UITableViewController {

    var post: Post?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        setUpNavigationBar()
        tableView.separatorStyle = .none
    }

    func setUpNavigationBar(){
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationItem.title = "\(post?.fromUser.login ?? "")"
        navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(self.options))]
    }
    
    @objc func options(){
        // drafts
        // saved
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let editAction = UIAlertAction(title: "Send via message", style: .default)
        let shareAction = UIAlertAction(title: "Send via project", style: .default)
        let settingsAction = UIAlertAction(title: "Copy link", style: .default)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(editAction)
        optionMenu.addAction(shareAction)
        optionMenu.addAction(settingsAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let mainView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        
        let scrollView = UIScrollView()
        
        scrollView.backgroundColor = .white
        
        mainView.addSubview(scrollView)
        scrollView.edgesToSuperview()
        
        scrollView.showsHorizontalScrollIndicator = false
        
        var buttons: [UIButton] = []
        for hash in post!.hashtags {
            let button = UIButton()
            button.setTitle("#" + hash, for: .normal)
            button.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            button.layer.cornerRadius = 10
            button.titleLabel?.font = UIFont.systemFont(ofSize: 14)
            button.setTitleColor(.black, for: .normal)
            buttons.append(button)
        }
        
        let stackView = UIStackView(arrangedSubviews: buttons)
        
        scrollView.addSubview(stackView)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 20
        
        stackView.edgesToSuperview(insets: .left(20) + .top(10) + .right(20))
        
        scrollView.contentSize = CGSize(width: 500, height: 50)
        
        switch section {
        case 0:
            return mainView
        default:
            return nil
        }
    }
    
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 50
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section {
        case 0:
            return 1
        case 1:
            return post?.comments.count ?? 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // TODO: make different cells for sections with switch
        
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellId) as! PostViewCell
        
        cell.fill(with: post!.dataArray, true)
        cell.selectionStyle = .none
        return cell
    }
    
}
