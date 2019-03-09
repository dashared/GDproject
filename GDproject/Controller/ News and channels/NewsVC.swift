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
    
    var dataSourse: [Model.Posts] = []{
        didSet{
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
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = viewController!.storyboard!.instantiateViewController(withIdentifier: fullPostControllerId) as! FullPostController
        
        vc.post = dataSourse[indexPath.row]
        viewController!.navigationController!.pushViewController(vc, animated: true)
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
        case .NONE:
            cell.onUserDisplay = { (id) in
                print("tapped when profile is open already \(id)")
            }
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


enum HeaderType {
    case NONE
    case NEWS
}
