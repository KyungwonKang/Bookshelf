//
//  URLSessionManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

enum APIError: Error {
    case noData
    case decodingJSON
    case requestFail(error: Error)
}

class URLSessionManager {
    static func get(url: URL, completion: @escaping (Result<Data, APIError>) -> Void) -> URLSessionDataTask{
        var request = URLRequest(url: url)
        request.httpMethod = "get"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let data = data {
                completion(Result.success(data))
            } else if let error = error {
                completion(Result.failure(.requestFail(error: error)))
            } else {
                completion(Result.failure(.noData))
            }
        }
        task.resume()
        return task
    }
    
    static func getImageData(url: URL, completion: @escaping (Result<Data, APIError>) -> Void) -> URLSessionDataTask {
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let data = data {
                completion(Result.success(data))
            } else if let error = error {
                completion(Result.failure(.requestFail(error: error)))
            } else {
                completion(Result.failure(.noData))
            }
        }
        task.resume()
        return task
    }
}
