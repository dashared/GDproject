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
    static var url = URL(string:"https://valera-denis.herokuapp.com/authenticate")!
    static var url1 = URL(string:"https://valera-denis.herokuapp.com/posts/last")!
    static var urlForDrafts = URL(string:"https://valera-denis.herokuapp.com/drafts/create")!
    static var urlForPublish = URL(string:"https://valera-denis.herokuapp.com/drafts/publish")!
    static var urlForUpdate = URL(string:"https://valera-denis.herokuapp.com/drafts/update")!
    static var urlForPostsForUser = URL(string:"https://valera-denis.herokuapp.com/posts/forUser")!
    static var urlForUsers = URL(string:"https://valera-denis.herokuapp.com/users")!
    
    struct Posts: Codable {
        var body: [Attachments]
        var authorId: Int
        var id: Int
        var user: Model.Users?
        
        init(body: [Attachments], authorId: Int, id: Int) {
            self.body = body
            self.authorId = authorId
            self.id = id
        }
        
        init(body: [Attachments], authorId: Int, id: Int, user: Model.Users) {
            self.body = body
            self.authorId = authorId
            self.id = id
            self.user = user
        }
        
        mutating func setUser(with: Users){
            self.user = with
        }
    }
    
    struct Users: Codable{
        var secondName: String
        var firstName: String
        var id: Int
    }
    
    struct Attachments: Codable {
        var markdown: String
        
        init(markdown: String) {
            self.markdown = markdown
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
            
            guard let realResponse = responce.response, realResponse.statusCode == 204 else {
                print("Not a 204 response")
                completion(false)
                return
            }
            
            let fields = realResponse.allHeaderFields as? [String :String]
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: realResponse.url!)
            
            HTTPCookieStorage.shared.setCookie(cookies[0])
            
            DataStorage.standard.setIsLoggedIn(value: true)
            completion(true)
        }
    }
    
    
    static func getLast(completion: @escaping ((Channel)->())){
        let jsonString = "100"
        var request = URLRequest(url: url1)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonString.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            if response.response?.statusCode == 200 {
                print("success")
            } else {
                print(response.response?.statusCode)
            }
            
            let decoder = JSONDecoder()
            guard let json = response.data else { return }
        
            guard let newPost = try? decoder.decode([Posts].self, from: json) else {  return }
            
            completion(Channel(title: "# General", subtitle: "No subtitle", hashtags: ["ПИ"], people: ["No"], posts: newPost))
        }
    }
    
    static func createDraft(completion: @escaping  ((Int)->())){
        let jsonString = "[{ \"markdown\": \"# This is a markdown title\nThis is body.\" }]"
        var request = URLRequest(url: urlForDrafts)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonString.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            if response.response?.statusCode == 200 {
                print("success in creating draft")
            } else {
                print("\(response.response?.statusCode ?? 0)")
            }
            
            //let decoder = JSONDecoder()
            guard let json = response.data else { return }
            
            guard let id = String(data: json, encoding: String.Encoding.utf8) else {return}

            print("with id \(id)")
            completion(Int(id) ?? 0)
        }
    }
    
    static var seeMe: Int = 0 {
        didSet{
            publish()
        }
    }
    
    static func publish(){
        let jsonUpd = "\(seeMe)"
        var request = URLRequest(url: urlForPublish)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonUpd.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            if response.response?.statusCode == 204 {
                print("successfuly published \(jsonUpd)")
            }
        }
    }
    
    static func update(post: Posts){
        let transformed = post.body.reduce("") { (res, att) -> String in
            res  + att.markdown
        }
        
        let jsonUpd = """
            {
            "body": [
                        {
                            "markdown": "\(transformed)"
                        }
                    ],
            "id": \(post.id)
            }
        """
        var request = URLRequest(url: urlForUpdate)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonUpd.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            if response.response?.statusCode == 204 {
                print("successfuly updated \(post.id) with \(jsonUpd)")
                seeMe = post.id
            } else {
                print(response.response?.statusCode)
            }
        }
    }
    
    
    static func getPostsForUser(with id: Int, completion: @escaping (([Posts])->())){
        let json = [
            "userId" : id,
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
            
            guard let newPost = try? decoder.decode([Posts].self, from: json) else {  return }
            
            completion(newPost)
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
}
