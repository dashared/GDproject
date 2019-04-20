//
//  NewsVC.swift
//  GDproject
//
//  Created by cstore on 15/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit
import MarkdownKit

struct PostCellData{
    var attributedData = NSAttributedString()
    
    static func create(with attachments: [Model.Attachments]) -> NSAttributedString{
        var markdown = ""
        
        attachments.forEach { (attachment) in markdown.append(attachment.markdown) }
        
        let markdownParser = MarkdownParser(font: UIFont.systemFont(ofSize: 16))
        markdownParser.enabledElements = .disabledAutomaticLink
        markdownParser.code.textBackgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        
        return markdownParser.parse(markdown)
    }
}

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var onChannelDidChange: ((([Int: Model.Users],[Model.Posts]))->())?
    
    var onFullPost: ((HeaderType, Model.Posts)->())?
    
    var dataSourse: [Model.Posts] = [] {
        didSet {
            cellDataSourse = []
            dataSourse.forEach { (item) in
                cellDataSourse.append(PostCellData(attributedData: PostCellData.create(with: item.body)))
            }
        }
    }
    
    var cellDataSourse: [PostCellData] = []
    
    var type: HeaderType = .NONE
    
    weak var viewController: UIViewController?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        onFullPost?(type, dataSourse[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSourse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: postCellId, for: indexPath) as! PostViewCell
        
        cell.fill(with: cellDataSourse[indexPath.row].attributedData, false, post: dataSourse[indexPath.row])
        
        switch type {
        case .NEWS:
            cell.onUserDisplay = { [weak self] (id) in
                let vc = self?.viewController!.storyboard!.instantiateViewController(withIdentifier: profileViewController) as! ProfileViewController
                vc.idProfile = id
                self?.viewController!.navigationController!.pushViewController(vc, animated: true)
            }
        default:
            cell.onUserDisplay = { (id) in
                print("tapped when profile is open already \(id)")
            }
        }
        
        cell.onAnonymousChannelDisplay = {
            [weak self] (tag) in
            Model.getAnonymousChannel(by: Model.AnonymousChannel(people: [], tags: [tag]),
                                      completion: { (tuple) in self?.onChannelDidChange?(tuple) }
            )
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
}

//extension NewsVC {
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
//    {
//        if let currentCell = sender as? PostViewCell,
//            let vc = segue.destination as? FullPostController {
//
//        }
//    }
//}

enum HeaderType {
    case NONE
    case NEWS
    case ANONYMOUS
}
