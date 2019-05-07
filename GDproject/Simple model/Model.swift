//
//  Model.swift
//  GDproject
//
//  Created by cstore on 23/02/2019.
//  Copyright © 2019 drHSE. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Model{
    
    static let invalidTocken = 498
    
    static var hashTagTree: CompletionTree? 
    
    private static var isValidTocken: ((Int)->())? = { responce in
        print(responce)
        if responce == invalidTocken {
            DataStorage.standard.setIsLoggedIn(value: false, with: 0)
            (UIApplication.shared.delegate as! AppDelegate).relaunch()
        }
    }
    
    private static let baseUrl = "https://valera-denis.herokuapp.com"
    static let decoder = JSONDecoder()
    
    static let authenticationURL = URL(string:"\(baseUrl)/authentication/login")!
    static let postsLastURL = URL(string:"\(baseUrl)/posts/last")!
    static let postsForUserURL = URL(string:"\(baseUrl)/posts/forUser")!
    static let postsPublishURL = URL(string:"\(baseUrl)/posts/publish")!
    static let usersURL = URL(string:"\(baseUrl)/users")!
    static let usersAllURL = URL(string:"\(baseUrl)/users/all")!
    static let channelsGetURL = URL(string: "\(baseUrl)/channels/get")!
    static let channelsUpdateURL = URL(string: "\(baseUrl)/channels/update")!
    static let channelsListURL = URL(string: "\(baseUrl)/channels")!
    static let channelsCreateURL = URL(string: "\(baseUrl)/channels/create")!
    static let channelsDeleteURL = URL(string: "\(baseUrl)/channels/delete")!
    static let channelsGetAnonURL = URL(string: "\(baseUrl)/channels/getAnonymous")!
    static let complexURL = URL(string: "\(baseUrl)/complex")!
    static let hashTagTreeURL = URL(string: "\(baseUrl)/tags/completions")!
    static let createGroupChatURL = URL(string: "\(baseUrl)/chats/createGroupChat")!
    static let chatsGetAllURL = URL(string: "\(baseUrl)/chats/getAll")!
    static let getGroupChatURL = URL(string: "\(baseUrl)/chats/getGroupChat")!
    static let leaveGroupChatURL = URL(string: "\(baseUrl)/chats/leaveGroupChat")!
    static let updateGroupChatURL = URL(string: "\(baseUrl)/chats/updateGroupChat")!
    static let messagesGetGroupChatURL = URL(string: "\(baseUrl)/messages/get/groupChat")! //r
    static let messagesSendURL = URL(string: "\(baseUrl)/messages/send")!
    static let messagesGetUserChatURL = URL(string: "\(baseUrl)/messages/get/userChat")!
    
    
    struct QueryPosts<T: Codable>: Codable {
        var users: [Int: Users]
        var response: [T]
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
        
        func fullName() -> String {
            return "\(firstName) \(lastName)"
        }
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
    
    struct Channels: Codable {
        
        // static var fullTags = Set<String>()
        static var fullPeople = [Users]()
        static var fullPeopleDict = [Int:Users]()
        
        var people: [Int]
        var name: String
        var id: Int?
        var tags: [String]
        
        init(people: [Int], name: String, id: Int, tags: [String]) {
            self.id = id
            self.people = people
            self.tags = tags
            self.name = name
        }
        
        init(people: [Int], name: String, tags: [String]) {
            self.people = people
            self.tags = tags
            self.name = name
        }
        
        enum CodingKeys: String, CodingKey {
            case people
            case name
            case id
            case tags
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(people, forKey: .people)
            try container.encode(name, forKey: .name)
            try container.encode(id, forKey: .id)
            try container.encode(tags, forKey: .tags)
        }
    }
    
    static func authenticate(with id: Int, completion: @escaping ((Bool)->())) {
        
        let json: [String:Any] = ["authenticationId" : id]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        
        var request = URLRequest(url: authenticationURL)
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
    
    struct GeneralRequest<T: Codable>: Codable
    {
        var direction: String
        var limit: Int
        var exclusiveFrom: Int?
        var request: T
        
        init(direction: String = "backward", limit: Int, exclusiveFrom: Int?, request: T) {
            self.direction = direction
            self.limit = limit
            self.exclusiveFrom = exclusiveFrom
            self.request = request
        }
        
        enum CodingKeys: String, CodingKey {
            case limit
            case exclusiveFrom
            case request
            case direction
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(limit, forKey: .limit)
            try container.encode(exclusiveFrom, forKey: .exclusiveFrom)
            try container.encode(request, forKey: .request)
            try container.encode(direction, forKey: .direction)
        }
    }
    
    static func getLast(on limit: Int = 10, from pointInTime: Int? = nil, completion: @escaping (((users:[Int: Users], posts:[Posts]))->()))
    {
        let postRequest = GeneralRequest<[Int]>(limit: limit, exclusiveFrom: pointInTime, request: [])
        
        var request = URLRequest(url: postsLastURL)
        request.httpBody = try? JSONEncoder().encode(postRequest)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            
            guard let newQueery = try? decoder.decode(QueryPosts<Posts>.self, from: json) else { print("no")
                return }
            
            idUser = newQueery.users
            completion((newQueery.users, newQueery.response))
        }
    }
    
    
    static func createAndPublish(body: [Attachments], tags: [String]){
        let jsonUpd = CreatedPost(body: body, tags: tags)
        var request = URLRequest(url: postsPublishURL)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = try? JSONEncoder().encode(jsonUpd)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
        }
    }
    
//    static func requestForPosts(limit: Int = 10, ){
//
//    }
    
    static func getPostsForUser(for limit: Int = 10, from pointInTime: Int? = nil, with id: Int, completion: @escaping (([Posts])->()))
    {
        let postsRequest = GeneralRequest<Int>(limit: limit, exclusiveFrom: pointInTime, request: id)
        
        let jsonData = try? JSONEncoder().encode(postsRequest)
        
        var request = URLRequest(url: postsForUserURL)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            
            guard let newPost = try? decoder.decode(QueryPosts<Posts>.self, from: json) else {  return }
            
            completion(newPost.response)
        }
    }
    
    static var idUser: [Int:Users] = [:]
    
    static func getUsers(for ids: [Int], completion: @escaping (([Int:Users])->())){
        let json = "\(Set(ids))"
        print(json)
        var request = URLRequest(url: usersURL)
        
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = json.data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            
            guard let users = try? decoder.decode([Users].self, from: json) else {  return }
            
            var dict: [Int:Users] = [:]
            users.forEach({ (user) in
                dict[user.id] = user
            })
            
            completion(dict)
        }
    }
    
    // get channel (with id): in responce -- PostQuery
    static func getChannel(with channelId: Int, on limit: Int = 10, from pointInTime: Int? = nil, completion: @escaping (((users:[Int: Users], posts:[Posts]))->()))
    {
        let postRequest = GeneralRequest<Int>(limit: limit, exclusiveFrom: pointInTime, request: channelId)
        let jsonData = try? JSONEncoder().encode(postRequest)
        
        var request = URLRequest(url: channelsGetURL)
        request.httpMethod = "POST"
        
        // insert json data to the request
        request.httpBody = jsonData
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            
            guard let json = response.data else { return }
            
            guard let newQueery = try? decoder.decode(QueryPosts<Posts>.self, from: json) else {  return }
            
            idUser = newQueery.users
            completion((newQueery.users, newQueery.response))
        }
    }
    
    
    static func createChannel(with channel: Channels) {
        
        var request = URLRequest(url: channelsCreateURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(channel)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
        }
        
    }
    
    static func channelsList(completion: @escaping (([Channels])->())){
        var request = URLRequest(url: channelsListURL)
        request.httpMethod = "POST"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON { (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            
            guard let channelsList = try? decoder.decode([Channels].self, from: json) else { return }
            
            completion(channelsList)
        }
    }
    
    static func channelsDelete(by id: Int, completion: @escaping(()->())){
        var request = URLRequest(url: channelsDeleteURL)
        request.httpMethod = "POST"
        request.httpBody = "\(id)".data(using: .utf8)
        print("\(id)")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (response) in
            isValidTocken?(response.response?.statusCode ?? 498)
        }
        completion()
    }
    
    static func updateChannel(with channel: Channels) {
        
        var request = URLRequest(url: channelsUpdateURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(channel)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
        }
    }
    
    static func usersAllGet() {
        var request = URLRequest(url: usersAllURL)
        request.httpMethod = "POST"
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            guard let json = response.data else { return }
            
            guard let users = try? decoder.decode([Users].self, from: json) else { return }
            
            Channels.fullPeople = users
            Channels.fullPeopleDict = users.reduce([Int: Users]()) { (dict, person) -> [Int: Users] in
                var dict = dict
                dict[person.id] = person
                return dict
            }
            
            isValidTocken?(response.response?.statusCode ?? 498)
        }
    }
    
    struct AnonymousChannel: Codable {
        
        var limit = 10
        var request: RequestPeopleTags
        
        enum CodingKeys: String, CodingKey {
            case limit
            case request
        }
        
        init(people: [Int], tags: [String]) {
            self.request = RequestPeopleTags(people: people, tags: tags)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(limit, forKey: .limit)
            try container.encode(request, forKey: .request)
        }
        
        struct RequestPeopleTags: Codable {
            
            var people: [Int]
            var tags: [String]
            
            init(people: [Int], tags: [String]) {
                self.people = people
                self.tags = tags
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(people, forKey: .people)
                try container.encode(tags, forKey: .tags)
            }
            
            enum CodingKeys: String, CodingKey {
                case people
                case tags
            }
            
        }
    }
    /*
     {
     "limit": 11,
     "request": {
         "people": [
                2,
                7,
                8
            ],
         "tags": [
                "thisIsHashTag",
                "thisIsAlsoHashTag"
            ]
         }
     }
     */
    static func getAnonymousChannel(by anonymousChannel: Model.Channels, exclusiveFrom: Int? = nil, completion: @escaping (((users:[Int: Users], posts:[Posts]))->())){
       
        let req = GeneralRequest<Model.Channels>(limit: 10, exclusiveFrom: exclusiveFrom, request: anonymousChannel)
        
        var request = URLRequest(url: channelsGetAnonURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(req)
        
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        AF.request(request).response {
            (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            
            guard let newQueery = try? decoder.decode(QueryPosts<Posts>.self, from: json) else {  return }
            
            // idUser = newQueery.users
            completion((newQueery.users, newQueery.response))
        }
    }
    
    static func getCompl(completion: @escaping ((CompletionTree)->())) {
        
        AF.request(URLRequest(url: hashTagTreeURL)).responseJSON {
            (response) in
            isValidTocken?(response.response?.statusCode ?? 498)
            guard let json = response.data else { return }
            guard let tree = try? decoder.decode(CompletionTree.self, from: json) else {  return }
            completion(tree)
        }
    }
    
    static func getChatAll(limit: Int = 10, exclusiveFrom: Int? = nil, request: [Int] = [], completion: @escaping ((([Dialog],[Int:Model.Users]))->()))
    {
        let req = GeneralRequest<[Int]>(limit: limit, exclusiveFrom: exclusiveFrom, request: request)
        var request = URLRequest(url: chatsGetAllURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(req)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).responseJSON { response in
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            let dialogs = try! decoder.decode(QueryPosts<Dialog>.self, from: json)
            
            completion((dialogs.response,dialogs.users))
        }
    }
    
    enum Dialog: Codable
    {
        case groupChat(GroupChat)
        case userChat(UserChat)
        
        private enum DialogKeys: CodingKey{
            case groupChat
            case userChat
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: DialogKeys.self)
            if container.contains(.groupChat){
                self = .groupChat(try GroupChat(from: container.superDecoder(forKey: .groupChat)))
            } else if container.contains(.userChat){
                self = .userChat(try UserChat(from: container.superDecoder(forKey: .userChat)))
            } else {
                throw DecodingError.keyNotFound(DialogKeys.groupChat, DecodingError.Context(codingPath: container.codingPath, debugDescription: "hz"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DialogKeys.self)
            switch self{
            case .groupChat(let chat):
                try chat.encode(to: container.superEncoder(forKey: .groupChat))
            case .userChat(let chat):
                try chat.encode(to: container.superEncoder(forKey: .userChat))
            }
        }
    }
    
    struct GroupChat: Codable {
        var group: Group
        var lastMessage: LastMessage?
        
        
        init(group: Group, lastMessage: LastMessage? = nil) {
            self.group = group
            self.lastMessage = lastMessage
        }
    }
    
    struct UserChat: Codable {
        var user: Int
        var lastMessage: LastMessage
    }
    
    struct Group: Codable {
        var users: [Int: UserPermission]
        var name: String
        var id: Int
        
        init(users: [Int: UserPermission] = [:], name: String = "", id: Int) {
            self.id = id
            self.users = users
            self.name = name
        }
    }
    
    struct UserPermission: Codable {
        var isAdmin: Bool
    }
    
    struct LastMessage: Codable {
        var body: Attachments
        var destination: MessageDestination
        var time: String
        var author: Int
        var id: Int
        
        enum MessageCodingKeys: CodingKey{
            case user
            case group
            case body
            case time
            case author
            case id
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: MessageCodingKeys.self)
            time = try container.decode(String.self, forKey: .time)
            body = try container.decode(Attachments.self, forKey: .body)
            author = try container.decode(Int.self, forKey: .author)
            id = try container.decode(Int.self, forKey: .id)
            
            if container.contains(.user){
                destination = MessageDestination.userChatDestination(try Int(from: container.superDecoder(forKey: .user)))
            } else if container.contains(.group){
                destination = MessageDestination.groupChatDestination(try Int(from: container.superDecoder(forKey: .group)))
            } else {
                throw DecodingError.keyNotFound(MessageCodingKeys.group, DecodingError.Context(codingPath: container.codingPath, debugDescription: "hz gr"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: MessageCodingKeys.self)
            
            try container.encode(time, forKey: .time)
            try container.encode(id, forKey: .id)
            try container.encode(author, forKey: .author)
            try container.encode(body, forKey: .body)
            
            switch destination {
            case .userChatDestination(let uId):
                try uId.encode(to: container.superEncoder(forKey: .user))
            case .groupChatDestination(let gId):
                try gId.encode(to: container.superEncoder(forKey: .group))
            }
        }
    }
    
    enum MessageDestination: Codable
    {
        func encode(to encoder: Encoder) throws
        {
            var container = encoder.container(keyedBy: MessCodingKeys.self)
            switch self {
            case .userChatDestination(let uId):
                try uId.encode(to: container.superEncoder(forKey: .user))
            case .groupChatDestination(let gId):
                try gId.encode(to: container.superEncoder(forKey: .group))
            }
        }
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: MessCodingKeys.self)
            if container.contains(.user){
                self = .userChatDestination(try Int(from: container.superDecoder(forKey: .user)))
            } else if container.contains(.group){
                self = .groupChatDestination(try Int(from: container.superDecoder(forKey: .group)))
            } else {
                throw DecodingError.keyNotFound(MessCodingKeys.group, DecodingError.Context(codingPath: container.codingPath, debugDescription: "hz gr"))
            }
        }
        
        enum MessCodingKeys: CodingKey{
            case user
            case group
        }
        
        case userChatDestination(Int)
        case groupChatDestination(Int)
        
    }
    
    static func createGroupChat(from group: Group, completion: @escaping ((Int)->())) {
        let req = group
        var request = URLRequest(url: createGroupChatURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(req)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            let stringInt = String.init(data: json, encoding: String.Encoding.utf8)
            let intId = Int.init(stringInt!)
            
            completion(intId!)
        }
    }
    
    static func getMessagesFor(typeOfChat: Model.Dialog, chat id: Int, exclusiveFrom: Int? = nil, limit l: Int = 10, direction: String = "backward", completion: @escaping (([LastMessage])->()))
    {
        let req = GeneralRequest<Int>(direction: direction, limit: l, exclusiveFrom: exclusiveFrom, request: id)
        var request: URLRequest?
        
        switch typeOfChat {
        case .groupChat:
            request = URLRequest(url: messagesGetGroupChatURL)
        case .userChat:
            request = URLRequest(url: messagesGetUserChatURL)
        }
        
        request!.httpMethod = "POST"
        request!.httpBody = try? JSONEncoder().encode(req)
        request!.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request!).response { (response) in
            
            isValidTocken?(response.response?.statusCode ?? 498)
            
            guard let json = response.data else { return }
            guard let messages = try? decoder.decode([LastMessage].self, from: json) else {  return }
            
            completion(messages)
        }
    }
    
    static func leaveGroupChat(id: Int, completion: @escaping (()->()))
    {
        var request = URLRequest(url: leaveGroupChatURL)
        request.httpMethod = "POST"
        request.httpBody = "\(id)".data(using: .utf8)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (response) in
            isValidTocken?(response.response?.statusCode ?? 498)
        }
        
        completion()
    }
    
    static func updateGroupChat(with group: Model.Group)
    {
        var request = URLRequest(url: updateGroupChatURL)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(group)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        
        AF.request(request).response { (response) in
            isValidTocken?(response.response?.statusCode ?? 498)
        }
        
        // completion()
    }
    
    struct SendMessage: Codable {
        var body: Attachments
        var destination: MessageDestination
        
        init(from decoder: Decoder) throws
        {
            let container = try decoder.container(keyedBy: LastMessage.MessageCodingKeys.self)
            body = try container.decode(Attachments.self, forKey: .body)
            
            if container.contains(.user){
                destination = MessageDestination.userChatDestination(try Int(from: container.superDecoder(forKey: .user)))
            } else if container.contains(.group){
                destination = MessageDestination.groupChatDestination(try Int(from: container.superDecoder(forKey: .group)))
            } else {
                throw DecodingError.keyNotFound(LastMessage.MessageCodingKeys.group, DecodingError.Context(codingPath: container.codingPath, debugDescription: "hz gr1"))
            }
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: LastMessage.MessageCodingKeys.self)
            try container.encode(body, forKey: .body)
            
            switch destination {
            case .userChatDestination(let uId):
                try uId.encode(to: container.superEncoder(forKey: .user))
            case .groupChatDestination(let gId):
                try gId.encode(to: container.superEncoder(forKey: .group))
            }
        }
        
        init(body: Attachments, destination: MessageDestination)
        {
            self.body = body
            self.destination = destination
        }
    }
    
    static func sendMessage(message: SendMessage, completion: @escaping (()->())){

        var request = URLRequest(url: messagesSendURL)
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(message)
        
        AF.request(request).response { (response) in
            isValidTocken?(response.response?.statusCode ?? 498)
            
            completion()
        }
    }
}
