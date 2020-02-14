//
//  BookModel.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/14.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation
import ObjectMapper

struct Book: Mappable {
    var title: String
    var subtitle: String?
    var isbn13: String?
    var price: String?
    var image: String?
    var url: String?
    
    init?(map: Map) {
        guard let title: String = map["title"].value() else { return nil }
        self.title = title
    }

    mutating func mapping(map: Map) {
        title       <- map["title"]
        subtitle    <- map["subtitle"]
        isbn13      <- map["isbn13"]
        price       <- map["price"]
        image       <- map["image"]
        url         <- map["url"]
    }
}
