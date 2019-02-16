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

    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
//    {
//
//    }
    
   
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
        
        cell.fill(with: post!.dataArray, true, post: post!)
        cell.selectionStyle = .none
        return cell
    }
    
}
