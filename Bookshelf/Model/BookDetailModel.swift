//
//  BookDetailModel.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation
import ObjectMapper

struct BookDetail: Mappable {
    var error: String?
    var title: String?
    var subtitle: String?
    var authors: String?
    var publisher: String?
    var isbn10: String?
    var isbn13: String?
    var pages: String?
    var year: String?
    var rating: String?
    var desc: String?
    var price: String?
    var image: String?
    var url: String?
    var pdf: [String]?
    
    init?(map: Map) {
        guard let title: String = map["title"].value() else { return nil }
        self.title = title
    }
    
    mutating func mapping(map: Map) {
        error       <- map["error"]
        title       <- map["title"]
        subtitle    <- map["subtitle"]
        authors     <- map["authors"]
        publisher   <- map["publisher"]
        isbn10      <- map["isbn10"]
        isbn13      <- map["isbn13"]
        pages       <- map["pages"]
        year        <- map["year"]
        rating      <- map["rating"]
        desc        <- map["desc"]
        price       <- map["price"]
        image       <- map["image"]
        url         <- map["url"]
        pdf         <- map["pdf"]
    }
}
