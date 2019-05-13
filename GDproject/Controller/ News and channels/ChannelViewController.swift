//
//  ChannelViewController.swift
//  MessageApp
//
//  Created by cstore on 02/05/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

protocol UpdatableName: class{
    func updateName(with name: String)
}

protocol UpdatableChannel: class{
    func updateChannel(with channel: Model.Channels)
}

class ChannelViewController: UITableViewController, UpdatableName, UpdatableChannel, TagsReceiver
{
    var onChoosingHashTags: (([String]?)->())?
    
    var onChoosingPeople: ((Model.Channels?)->())?
    
    func receiveTags(tags: [String]) {
        self.channel?.tags = tags
    }
    
    func updateName(with name: String){
        channel?.name = name
    }
    
    func updateChannel(with channel: Model.Channels) {
        self.channel = channel
    }
    
    var channel: Model.Channels?
    
    // func to show preview of the current channel
    var onShowingPreview: ((Model.Channels)->())?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        tableView.keyboardDismissMode = .onDrag
        navigationItem.rightBarButtonItems = [ UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(showPreview)), self.editButtonItem]
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "searchCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        defer {
            super.viewWillDisappear(animated)
        }
        
        guard let _ = self.navigationController?.viewControllers.lastIndex(of: self) else
        {
            if let id = channel?.id, id != 0
            {
                Model.updateChannel(with: channel!)
            } else {
                Model.createChannel(with: channel!) {
                    [weak self] in
                    self?.showAlertOn(result: $0)
                    return
                }
            }
            return
        }
        // nou
    }
    
    @objc func showPreview()
    {
        if let channel = channel {
            onShowingPreview?(channel)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return (channel?.people.count ?? 0) + 1
        case 2:
            return (channel?.tags.count ?? 0) + 1
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 1:
            return "People"
        case 2:
            return "Tags"
        default:
            return "Title"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section{
        case 1 , 2:
            return whichCell(tableView, cellForRowAt: indexPath)
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleCell
            
            cell.fill(title: channel?.name)
            cell.update = self
            
            return cell
        }
    }
    
    private func whichCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let row = indexPath.row
        let section = indexPath.section
        
        if row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "searchCell")!
            cell.textLabel?.text = "Add more"
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if section == 1 {
            cell.textLabel?.text = "👤 \(Model.Channels.fullPeopleDict[channel?.people[row-1] ?? 0]!.fullName())"
        } else {
            cell.textLabel?.text = "# \(channel!.tags[row-1])"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == UITableViewCell.EditingStyle.delete
        {
            if indexPath.section == 1 {
                channel?.people.remove(at: indexPath.row-1)
            } else {
                channel?.tags.remove(at: indexPath.row-1)
            }
        }
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == 0 {
            return false
        }
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if indexPath.row == 0 && indexPath.section == 1
        {
            onChoosingPeople?(channel)
        }
        
        if indexPath.row == 0 && indexPath.section == 2 {
            onChoosingHashTags?(channel?.tags)
        }
    }
}


class TitleCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var titleLabel: UITextField!
    
    weak var update: UpdatableName?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func fill(title: String?){
        titleLabel.text = title
        titleLabel.addTarget(self, action: #selector(changedText(_:)), for: .editingChanged)
    }
    
    @objc func changedText(_ textField: UITextField){
        update?.updateName(with: textField.text!)
    }
}
