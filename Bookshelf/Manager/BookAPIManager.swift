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
    static func loadNewBookLists(newBooksLoaded: @escaping (NewReleasedBooks) -> Void) {
        if let url = URL(string: IT_BOOK_API_URL + "new") {
            URLSessionManager.get(url: url, success: { (json) in
                if let newBooks = NewReleasedBooks(JSON: json) {
                    newBooksLoaded(newBooks)
                }
            }) { (error) in
                print("Load new book lists error: \(error?.localizedDescription ?? "")")
            }
        }
    }
    
    static func loadBookInfo(isbn13: String, bookDetailLoaded: @escaping (BookDetail) -> Void) {
        if let url = URL(string: IT_BOOK_API_URL + "books/\(isbn13)") {
            URLSessionManager.get(url: url, success: { (json) in
                if let bookDetail = BookDetail(JSON: json) {
                    bookDetailLoaded(bookDetail)
                }
            }) { (error) in
                print("Load book detail info error: \(error?.localizedDescription ?? "")")
            }
        }
    }

}
