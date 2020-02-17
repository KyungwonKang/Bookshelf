//
//  BookAPIManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

let IT_BOOK_API_URL = "https://api.itbook.store/1.0/"

class BookAPIManager {
    @discardableResult
    static func loadNewBookLists(completion: @escaping (Result<NewReleasedBooks, APIError>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: IT_BOOK_API_URL + "new") else {
            return nil
        }
        
        let task = URLSessionManager.get(url: url) { (result) in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let newBooks = NewReleasedBooks(JSON: json) {
                    completion(Result.success(newBooks))
                } else {
                    completion(Result.failure(.decodingJSON))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
        
        return task
    }
    
    @discardableResult
    static func loadBookInfo(isbn13: String, completion: @escaping (Result<BookDetail, APIError>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: IT_BOOK_API_URL + "books/\(isbn13)") else {
            return nil
        }
        
        let task = URLSessionManager.get(url: url) { (result) in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let bookDetail = BookDetail(JSON: json) {
                    completion(Result.success(bookDetail))
                } else {
                    completion(Result.failure(.decodingJSON))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
        return task
    }
    
    @discardableResult
    static func searchBooks(searchText: String, page: Int = 1, completion: @escaping (Result<SearchedBooks, APIError>) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: IT_BOOK_API_URL + "search/\(searchText)/\(page)") else {
            return nil
        }
        
        let task = URLSessionManager.get(url: url) { (result) in
            switch result {
            case .success(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let searchedBooks = SearchedBooks(JSON: json) {
                    completion(Result.success(searchedBooks))
                } else {
                    completion(Result.failure(.decodingJSON))
                }
            case .failure(let error):
                completion(Result.failure(error))
            }
        }
        return task
    }
}
