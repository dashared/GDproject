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

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    var onChannelDidChange: ((([Int: Model.Users],[Model.Posts]))->())?
    
    var onFullPost: ((HeaderType, Model.Posts)->())?
    
    var dictionary: [Int: Model.Users] = [:] {
        didSet {
            
            dataSourse = dataSourse.map {
                var copy = $0
                copy.user = dictionary[$0.authorId]
                return copy
            }
            
            (viewController as? NewsController)?.tableView.reloadData()
        }
    }
    
    var currChannel : Model.Channels?
    
    var dataSourse: [Model.Posts] = [] {
        didSet {
            cellDataSourse = dataSourse.map { PostCellData(attributedData: PostCellData.create(with: $0.body)) }
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
            
            cell.onAnonymousChannelDisplay = {
                [weak self] in
                (self?.viewController as? UpdateableWithChannel)?.updateChannel(on: Model.Channels(people: [], name: $0, id: 0, tags: [$0]))
            }
        default:
            cell.onUserDisplay = { (id) in
                print("tapped when profile is opened already \(id)")
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
    
    var prevLast = -1
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        // pagination
        if indexPath.row == cellDataSourse.count - 1 && prevLast != indexPath.row
        {
            if let ch = currChannel, let id = ch.id, id != -1 {
                // check this!
                Model.getAnonymousChannel(by: ch, exclusiveFrom: dataSourse.last?.id) { [weak self] in
                    self?.dataSourse.append(contentsOf: $0.posts)
                    $0.users.forEach { self?.dictionary[$0.key] = $0.value }
                }
                
            } else {
                // check this!
                Model.getLast(on: 10, from: dataSourse.last?.id )
                { [weak self] in
                    self?.dataSourse.append(contentsOf: $0.posts)
                    $0.users.forEach { self?.dictionary[$0.key] = $0.value }
                }
            }

            prevLast = indexPath.row
        }
    }
}

enum HeaderType {
    case NONE
    case NEWS
    case ANONYMOUS
}
