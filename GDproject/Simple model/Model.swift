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
    
    private static let baseUrl = "https://valera-denis.herokuapp.com"
    
    static let url = URL(string:"\(baseUrl)/authenticate")!
    static let url1 = URL(string:"\(baseUrl)/posts/last")!
    static let urlForDrafts = URL(string:"\(baseUrl)/drafts/create")!
    static let urlForPublish = URL(string:"\(baseUrl)/drafts/publish")!
    static let urlForUpdate = URL(string:"\(baseUrl)/drafts/update")!
    static let urlForPostsForUser = URL(string:"\(baseUrl)/posts/forUser")!
    static let urlForUsers = URL(string:"\(baseUrl)/users")!
    static let createAndPublishURL = URL(string:"\(baseUrl)/drafts/createAndPublish")!
    
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
            
            DataStorage.standard.setIsLoggedIn(value: true, with: id)
            completion(true)
        }
    }
    
    
    static func getLast(completion: @escaping ((Channel)->())){
        let jsonString = "30"
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
    
    
    static func createAndPublish(string: String){
        let jsonUpd = """
            [
                {
                    "markdown": "\(string)"
                }
            ]
        """
        var request = URLRequest(url: createAndPublishURL)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonUpd.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            if response.response?.statusCode == 204 {
                print("post created")
            } else {
                print("failure in creating and publishing post")
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
