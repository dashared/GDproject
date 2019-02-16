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
        
        cell.fill(with: dataSourse[indexPath.row].dataArray, false)
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch type {
        case .NONE:
            return 0
        default:
            return 46
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: headerNewsChannelsVC) as! HeaderNewsChannels
        
        cell.vc = viewController as? NewsController
        cell.vcProfile = viewController as? ProfileViewController
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 46.0))
        view.addSubview(cell)
        cell.edgesToSuperview()
        
        switch type {
        case .NONE:
            return nil
        default:
            return view
        }
    }
    
}


enum HeaderType {
    case NONE
    case NEWS(String, String)
    case PROFILE(String, String)
    case BASIC_INFO(String, String)
}
