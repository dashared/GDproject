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
    
    static func authenticate(){
        
        let params: Parameters = ["authenticationId" : 9]
        AF.request(url, method: .post, parameters: params).response{
            (responce) in
            
            print(responce.response?.allHeaderFields)
        }
        
    }
}
