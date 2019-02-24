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
    
    struct Posts: Codable {
        var body: [Attachments]
        var authorId: Int
        var id: Int
        
        init(body: [Attachments], authorId: Int, id: Int) {
            self.body = body
            self.authorId = authorId
            self.id = id
        }
    }
    
    struct Attachments: Codable {
        var markdown: String
        
        init(markdown: String) {
            self.markdown = markdown
        }
    }
    
    static func authenticate(){
        
        let json: [String:Any] = ["authenticationId" : 9]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (responce) in
            
            guard let realResponse = responce.response, realResponse.statusCode == 204 else {
                print("Not a 204 response")
                return
            }
            
            let fields = realResponse.allHeaderFields as? [String :String]
            
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields!, for: realResponse.url!)
            
            
            for cookie in cookies {
                HTTPCookieStorage.shared.setCookie(cookie)
                DataStorage.standard.cookie = cookie
            }
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
        print(jsonUpd)
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
}
