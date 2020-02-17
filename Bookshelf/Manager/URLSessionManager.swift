//
//  URLSessionManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

class URLSessionManager {
    static func get(url: URL, success: @escaping (Data) -> Void, fail: @escaping (Error?) -> Void) -> URLSessionDataTask{
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                success(data)
            } else {
                fail(error)
            }
        }
        task.resume()
        return task
    }
    
    static func getImageData(url: URL, completion: @escaping (Data?) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            completion(data)
        }
        task.resume()
        return task
    }
}
