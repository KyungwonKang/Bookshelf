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
    static func loadNewBookLists(newBooksLoaded: @escaping (NewReleasedBooks) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: IT_BOOK_API_URL + "new") else {
            return nil
        }
        
        let task = URLSessionManager.get(url: url, success: { (data) in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let newBooks = NewReleasedBooks(JSON: json) {
                    newBooksLoaded(newBooks)
                }
            } catch {
                print("JSONSerialization error: \(error.localizedDescription)")
            }
        }) { (error) in
            print("Load new book lists error: \(error?.localizedDescription ?? "")")
        }
        return task
    }
    
    @discardableResult
    static func loadBookInfo(isbn13: String, bookDetailLoaded: @escaping (BookDetail) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: IT_BOOK_API_URL + "books/\(isbn13)") else {
            return nil
        }
        
        let task = URLSessionManager.get(url: url, success: { (data) in
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any],
                    let bookDetail = BookDetail(JSON: json) {
                    bookDetailLoaded(bookDetail)
                }
            } catch {
                print("JSONSerialization error: \(error.localizedDescription)")
            }
        }) { (error) in
            print("Load book detail info error: \(error?.localizedDescription ?? "")")
        }
        return task
    }
    
}
