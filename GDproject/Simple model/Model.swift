//
//  Model.swift
//  GDproject
//
//  Created by cstore on 23/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import Alamofire

class Model{
    static let invalidTocken = 498
    private static var isValidTocken: ((Int)->())? = {
        responce in
        print("\(responce)")
        if responce == invalidTocken {
            DataStorage.standard.setIsLoggedIn(value: false, with: 0)
        }
    }
    
    private static let baseUrl = "https://valera-denis.herokuapp.com"
    
    static let url = URL(string:"\(baseUrl)/authentication/login")!
    static let url1 = URL(string:"\(baseUrl)/posts/last")!
    static let urlForPostsForUser = URL(string:"\(baseUrl)/posts/forUser")!
    static let urlForUsers = URL(string:"\(baseUrl)/users")!
    static let createAndPublishURL = URL(string:"\(baseUrl)/posts/publish")!
    static let channelsGetURL = URL(string: "\(baseUrl)/channels/get")!
    
    
    struct QueryPosts: Codable{
        var users: [Int: Users]
        var posts: [Posts]
    }
    
    struct Posts: Codable {
        var body: [Attachments]
        var authorId: Int
        var id: Int
        var user: Model.Users?
        var updated: String
        var tags: [String]
        
        init(body: [Attachments], authorId: Int, id: Int, date: String,tags: [String]) {
            self.body = body
            self.authorId = authorId
            self.id = id
            self.updated = date
            self.tags = tags
        }
        
        init(body: [Attachments], authorId: Int, id: Int, user: Model.Users,  date: String, tags: [String]) {
            self.body = body
            self.authorId = authorId
            self.id = id
            self.user = user
            self.updated = date
            self.tags = tags
        }
        
        func convertDateFormatter() -> String
        {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"//this your string date format
            dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
            let date = dateFormatter.date(from: updated)
            
            dateFormatter.dateFormat = "MMM d, yyyy HH:mm" ///this is what you want to convert format
            dateFormatter.timeZone = NSTimeZone.local
            let timeStamp = dateFormatter.string(from: date!)
            
            return timeStamp
        }
    }
    
    struct CreatedPost: Codable {
        var body = [Attachments]()
        var tags = [String]()
        
        enum CodingKeys: String, CodingKey {
            case body
            case tags
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(body, forKey: .body)
            try container.encode(tags, forKey: .tags)
        }
    }
    
    struct Users: Codable{
        
        var middleName: String
        var lastName: String
        var firstName: String
        var id: Int
        
    }
    
    struct Attachments: Codable {
        var markdown: String
        
        init(markdown: String) {
            self.markdown = markdown
        }
        
        enum CodingKeys: String, CodingKey {
            case markdown
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(markdown, forKey: .markdown)
        }
    }
    
    static func authenticate(with id: Int, completion: @escaping ((Bool)->())) {
        
        let json: [String:Any] = ["authenticationId" : id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (responce) in
            
            guard let realResponse = responce.response, realResponse.statusCode == 200 else
            {
                print("Not a 200 response")
                completion(false)
                return
            }
            
            guard let json = responce.data else { return }
            guard let personId = Int(String(data: json, encoding: String.Encoding.utf8)!) else {
                completion(false)
                return
            }
            
            let fields = realResponse.allHeaderFields as? [String :String]
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: realResponse.url!)
            
            HTTPCookieStorage.shared.setCookie(cookies[0])
            
            DataStorage.standard.setIsLoggedIn(value: true, with: personId)
            completion(true)
        }
    }
    
    
    static func getLast(completion: @escaping (((users:[Int: Users], channel:Channel))->())){
        let jsonString = "30"
        var request = URLRequest(url: url1)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonString.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            let decoder = JSONDecoder()
            guard let json = response.data else { return }
            
            guard let newQueery = try? decoder.decode(QueryPosts.self, from: json) else { print("no")
                return }
            
            idUser = newQueery.users
            completion((newQueery.users, Channel(title: "# General", subtitle: "No subtitle", hashtags: ["ПИ"], people: ["No"], posts: newQueery.posts)))
        }
    }
    
    
    static func createAndPublish(body: [Attachments], tags: [String]){
        let jsonUpd = CreatedPost(body: body, tags: tags)
        
        var request = URLRequest(url: createAndPublishURL)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = try? JSONEncoder().encode(jsonUpd)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
        }
    }
    
    
    static func getPostsForUser(with id: Int, completion: @escaping (([Posts])->())){
        let json = [
            "request" : id,
            "limit": 10
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: urlForPostsForUser)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            if response.response?.statusCode == 200 {
                print("success")
            }
            
            let decoder = JSONDecoder()
            guard let json = response.data else { return }
            
            guard let newPost = try? decoder.decode(QueryPosts.self, from: json) else {  return }
            
            completion(newPost.posts)
        }
    }
    
    static var idUser: [Int:Users] = [:]
    
    static func getUsers(for ids: [Int], completion: @escaping (([Int:Users])->())){
        let json = "\(Set(ids))"
        print(json)
        var request = URLRequest(url: urlForUsers)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = json.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            if response.response?.statusCode == 200 {
                print("successddd")
            }
            
            let decoder = JSONDecoder()
            guard let json = response.data else { return }
            
            guard let users = try? decoder.decode([Users].self, from: json) else {  return }
            
            users.forEach({ (user) in
                Model.idUser[user.id] = user
            })
            
            completion(Model.idUser)
        }
    }
    
    // get channel (with id): in responce -- PostQuery
    static func getChannels(with channelId: Int, completion: @escaping (([Posts])->())){
        let json = [
            "request" : channelId,
            "limit": 10
        ]
        
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: urlForPostsForUser)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            if response.response?.statusCode == 200 {
                print("success")
            }
            
            let decoder = JSONDecoder()
            guard let json = response.data else { return }
            
            guard let newPost = try? decoder.decode(QueryPosts.self, from: json) else {  return }
            
            completion(newPost.posts)
        }
    }
}
