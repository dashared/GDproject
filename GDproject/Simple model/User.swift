//
//  User.swift
//  NewsFeed
//
//  Created by cstore on 12/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

struct User {
    //var photo: UIImage? = #imageLiteral(resourceName: "image")
    var login: String
    var id: Int
    var fullName: String
    var initials: (surname: String, name: String, optional: String?) = ("Богомазова","Вероника","Львовна")
    var placeOfWork: String?
    var faculty: String?
    let posts: [Post] =  []
    
    init(name: String, id: Int, fullName: String) {
        self.login = name
        self.id = id
        self.fullName = fullName
    }
    
    init(surname: String, name: String, optional: String?, emailName: String, id: Int, place: String?, faculty: String?)
    {
        self.id = id
        self.login = emailName
        self.initials = (surname, name, optional)
        
        self.fullName = "\(surname) \(name) \(optional ?? "")"
        self.placeOfWork = place
        if let f = faculty {
            self.faculty = f
        }
    }
}
