//
//  NewsVC.swift
//  GDproject
//
//  Created by cstore on 15/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

class NewsVC: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    var dataSourse: [Post] = []
    
    var type: HeaderType = .NONE
    
    var viewController: UIViewController?
    
    func numberOfSections(in tableView: UITableView) -> Int {
        switch type {
        case .NONE:
            return 1
        default:
            return 2
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 && type == .NEWS || type == .NONE {
            let vc = viewController!.storyboard!.instantiateViewController(withIdentifier: fullPostControllerId) as! FullPostController
            
            vc.post = dataSourse[indexPath.row]
            viewController!.navigationController!.pushViewController(vc, animated: true)
        }
        else if indexPath.section == 0 && type == .NEWS{
            let vc = viewController!.storyboard!.instantiateViewController(withIdentifier: channelListControllerId) as! ChannelListController
            
            viewController!.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .NONE:
            return dataSourse.count
        default:
            switch section {
            case 0:
                return 1
            default:
                return dataSourse.count
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        switch type {
        case .NONE:
            let cell = tableView.dequeueReusableCell(withIdentifier: postCellId, for: indexPath) as! PostViewCell
            
            cell.fill(with: dataSourse[indexPath.row].dataArray, false, post: dataSourse[indexPath.row])
            cell.selectionStyle = .none
            return cell
        default:
            switch indexPath.section {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
                cell.textLabel?.text = "List of channels"
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: postCellId, for: indexPath) as! PostViewCell
                
                cell.fill(with: dataSourse[indexPath.row].dataArray, false, post: dataSourse[indexPath.row])
                cell.selectionStyle = .none
                return cell
            }
        }
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
