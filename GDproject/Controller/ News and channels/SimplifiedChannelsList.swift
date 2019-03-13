//
//  SimplifiedChannelsList.swift
//  GDproject
//
//  Created by cstore on 13/03/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//


/// class for ADDing person to existing (or new) channel: like playlist in itunes
import UIKit
import TinyConstraints

class SimplifiedChannelsList: UITableViewController {
    
    var user: Model.Users?
    
    var dataSource: [Model.Channels]?{
        didSet{
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNavigationButtons()
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.setHidesBackButton(true, animated:true)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Model.channelsList { [weak self] (channels) in
            self?.dataSource = channels
        }
    }
    
    func setUpNavigationButtons(){
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelAction))
    }
    
    func completedActions(with channel: Model.Channels){
        Model.updateChannel(with: channel)
        cancelAction()
    }
    
    @objc func cancelAction(){
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.reveal
        transition.subtype = CATransitionSubtype.fromBottom
        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewHeader = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        let label = UILabel()
        
        label.text = "All channels"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        
        viewHeader.addSubview(label)
        label.edgesToSuperview(insets: .left(16))
        return viewHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var channel = dataSource![indexPath.row]
        channel.people.append(user!.id)
        completedActions(with: channel)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = dataSource![indexPath.row].name
        cell.detailTextLabel?.text = "\(dataSource![indexPath.row].id!)"
        
        return cell
    }
}
