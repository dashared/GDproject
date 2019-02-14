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
    var comments: [Comment]
    var hashtags: [String] = ["ФКН", "Подбельский", "НИУВШЭ", "Шершаков", "ПАД", "Интересное","Мемы","Забавное","Учеба","Наука"]
    
    init(dataArray: [Media], from: User, date: String, comments: [Comment] = [])
    {
        self.dataArray = dataArray
        fromUser = from
        atDate = date
        self.comments = comments
    }
}


enum Media{
    case text(String)
    case image([UIImage])
    case quote
}

struct Comment {
    var from: User
    var atTime: String
    var withData: String
}
