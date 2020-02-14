//
//  URLSessionManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

class URLSessionManager {
    static func get(url: URL, success: @escaping ([String : Any]) -> Void, fail: @escaping (Error?) -> Void) {
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] {
                        success(json)
                    } else {
                        fail(nil)
                    }
                } catch {
                    fail(error)
                }
            } else {
                fail(error)
            }
        }
        
        task.resume()
    }
    
    static func getImageData(url: URL, completion: @escaping (Data?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            completion(data)
        }
        task.resume()
    }
}
