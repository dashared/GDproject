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

    var post: Model.Posts?
    var type: HeaderType = .NONE
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(PostViewCell.self, forCellReuseIdentifier: postCellId)
        
        setUpNavigationBar()
        tableView.separatorStyle = .none
    }

    func setUpNavigationBar(){
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.title = "Post"
    }
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        switch section {
        case 0:
            let v = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 1))
            v.backgroundColor = .white
            return v
        default:
            return nil
        }
    }
    
   
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 1
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
            return 0
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        // TODO: make different cells for sections with switch
        
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellId) as! PostViewCell
        
        
        cell.fill(with: PostCellData.create(with: post!.body), true, post: post!)
        
        switch type {
        case .NEWS:
            cell.onUserDisplay = { [weak self] (id) in
                let vc = self?.storyboard!.instantiateViewController(withIdentifier: profileViewController) as! ProfileViewController
                vc.idProfile = id
                
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        default:
            break
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
}
