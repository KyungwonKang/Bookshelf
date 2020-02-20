//
//  UserDefaults+.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

let RECENTLY_SEARCHED_TEXTS = "recentely_searched_texts"

extension String {
    func getObject() -> Any? {
        return UserDefaults.standard.object(forKey: self)
    }
    
    func getStringArray() -> [String]? {
        return UserDefaults.standard.stringArray(forKey: self)
    }
    
    func save(array: [Any]?) {
        UserDefaults.standard.set(array, forKey: self)
    }
}
