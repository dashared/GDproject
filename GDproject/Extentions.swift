//
//  Extentions.swift
//  GDproject
//
//  Created by cstore on 15/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import UIKit

extension UIImage{
    var roundedImage: UIImage {
        let rect = CGRect(origin:CGPoint(x: 0, y: 0), size: self.size)
        UIGraphicsBeginImageContextWithOptions(self.size, false, 1)
        UIBezierPath(
            roundedRect: rect,
            cornerRadius: self.size.height
            ).addClip()
        self.draw(in: rect)
        return UIGraphicsGetImageFromCurrentImageContext()!
    }
}

extension UIView
{
    func addConstraintsWithFormat(format: String, views: UIView...){
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated(){
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
    }
}


extension UIStoryboard {
    
    private static let userEdit = UIStoryboard(name: "Main", bundle: nil)
    
    class func makeChannelsListController() -> ChannelListController {
        return UIStoryboard.userEdit.instantiateViewController(withIdentifier: channelListControllerId) as! ChannelListController
    }
    
    class func makeNewsController() -> NewsController {
        return UIStoryboard.userEdit.instantiateViewController(withIdentifier: newsController) as! NewsController
    }
}
