//
//  Channel.swift
//  GDproject
//
//  Created by cstore on 20/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation

class Channel {
    var title = String()
    var subtitle = String()
    
    var hashtags: [String] = []
    var people: [String] = []
    
    var posts: [Post] = []
    
    init(title: String, subtitle: String, hashtags: [String], people: [String], posts: [Post])
    {
        self.title = title
        self.subtitle = subtitle
        self.people = people
        self.hashtags = hashtags
        self.posts = posts
    }
}