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

}
