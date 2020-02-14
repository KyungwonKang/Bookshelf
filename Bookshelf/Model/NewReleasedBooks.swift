//
//  NewReleasedBooks.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation
import ObjectMapper

struct NewReleasedBooks: Mappable {
    var error: String?
    var total: String?
    var books: [Book]
    
    init?(map: Map) {
        self.books = []
    }
    
    mutating func mapping(map: Map) {
        error       <- map["error"]
        total       <- map["total"]
        books       <- map["books"]
    }
}
