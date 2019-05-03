//
//  DialogViewController.swift
//  GDproject
//
//  Created by cstore on 01/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class DialogViewController: UITableViewController {
    
    var onInfoShow: (()->())?
    var group: Model.Group?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        if let id = group {
            navigationItem.title = "🌌 \(id.id) \(id.name)"
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(moveToInfoVC))
        }
    }
    
    
    @objc func moveToInfoVC(){
        
    }
    
    var currentMessagesInChat: [Model.LastMessage]? {
        didSet {
            tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentMessagesInChat?.count ?? 0
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let group = group {
            Model.getMessagesForGroupChat(chat: group.id) { [unowned self]  in
                self.currentMessagesInChat = $0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.detailTextLabel?.text = currentMessagesInChat![indexPath.row].body.markdown
        cell.textLabel?.text = "\(currentMessagesInChat![indexPath.row].author)"
        
        return cell
    }
}
