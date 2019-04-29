//
//  Post.swift
//  NewsFeed
//
//  Created by cstore on 12/01/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit

enum Media{
    case text(String)
    case image([UIImage])
    case quote
}

struct Comment {
    var atTime: String
    var withData: String
}
