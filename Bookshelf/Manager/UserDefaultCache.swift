//
//  UserDefaultCache.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/25.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

class UserDefaultCache {
    enum Key: String {
        case recentSearch = "recentely_searched_texts"
    }
    
    static func object(forKey key: Key) -> Any? {
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    static func stringArray(forKey key: Key) -> [String]? {
        return UserDefaults.standard.stringArray(forKey: key.rawValue)
    }
    
    static func save(array: [Any]?, forKey key: Key) {
        UserDefaults.standard.set(array, forKey: key.rawValue)
    }
}
