//
//  AnonimousChannelController.swift
//  GDproject
//
//  Created by cstore on 20/04/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class TagsSuggestionController: UITableViewController
{
    weak var delegate: UpdateableWithChannel?
    
    var suggestions = [String]()
    var channel: Model.Channels?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        if let tree = Model.hashTagTree {
            suggestions = CompletionTree.getCompletion(tree: tree, word: "")
            print(suggestions)
        }
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return suggestions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = suggestions[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        channel = Model.Channels(people: [], name: "\(self.suggestions[indexPath.row])", id: 0, tags: [self.suggestions[indexPath.row]])
        
        delegate?.updateChannel(on: channel!)
        self.dismiss(animated: true)
    }
}
