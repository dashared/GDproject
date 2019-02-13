//
//  Post.swift
//  NewsFeed
//
//  Created by cstore on 12/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

struct Post {
    var dataArray: [Media]
    var fromUser: User
    var atDate: String
    
    init(dataArray: [Media], from: User, date: String)
    {
        self.dataArray = dataArray
        fromUser = from
        atDate = date
    }
}


enum Media{
    case text(String)
    case image([UIImage])
    case quote
}
