//
//  Channel.swift
//  GDproject
//
//  Created by cstore on 20/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation

class Channel: Equatable {
    static func == (lhs: Channel, rhs: Channel) -> Bool {
        return (lhs.title == rhs.title &&
                lhs.subtitle == rhs.subtitle &&
                lhs.people == rhs.people &&
                lhs.hashtags == rhs.hashtags)
    }
    
    var title = String()
    var subtitle = String()
    
    var hashtags: [String] = []
    var people: [String] = []
    
    var posts: [Model.Posts] = []
    
    init(title: String, subtitle: String = "none", hashtags: [String] = [], people: [String] = [], posts: [Model.Posts])
    {
        self.title = title
        self.subtitle = subtitle
        self.people = people
        self.hashtags = hashtags
        self.posts = posts
    }
}
