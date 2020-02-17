//
//  SearchedBooks.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/17.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation
import ObjectMapper

struct SearchedBooks: Mappable {
    var error: String?
    var total: String?
    var page: Int?
    var books: [Book]
    
    init?(map: Map) {
        self.books = []
    }
    
    mutating func mapping(map: Map) {
        error       <- map["error"]
        total       <- map["total"]
        page        <- map["page"]
        books       <- map["books"]
    }
}
