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
    
    class func tabBarController() -> UITabBarController{
        return UIStoryboard.userEdit.instantiateViewController(withIdentifier: "TabBar") as! UITabBarController
    }
    
    class func navRoot() -> UINavigationController{
        return UIStoryboard.userEdit.instantiateViewController(withIdentifier: "root") as! UINavigationController
    }
    
    class func makeLogIn() -> LogInViewController {
        return UIStoryboard.userEdit.instantiateViewController(withIdentifier: logInController) as! LogInViewController
    }
}


extension String {
    func getDate() -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let date = dateFormatter.date(from: self)
        
        dateFormatter.dateFormat = "MMM d, yyyy HH:mm" ///this is what you want to convert format
        dateFormatter.timeZone = NSTimeZone.local
        let timeStamp = dateFormatter.string(from: date!)
        
        return timeStamp
    }
}

extension UIViewController {
    func showAlertOn(result: ResultR) {
        
        let message: String
        
        switch result {
        case .impossibleContent:
            message = "Impossible content"
        case .exceededContent:
            message = "The content exceeded"
        case .longContent:
            message = "The content is too long"
        case .badAccess:
            message = "Try reloading the page again"
        case .alreadyRegistered:
            message = "User is already registered"
        case .tooMuchToAdd:
            message = "Limit of channels exceeded"
        case .success, .success1:
            return
        default:
            message = "Something went wrong"
        }
        
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
