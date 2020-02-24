//
//  RecentSearchManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

class SearchLogger {
    private var logs: [String] = []
    private let MAX_SAVE_COUNT = 5

    init() {
        if let logs = UserDefaultCache.stringArray(forKey: .recentSearch) {
            self.logs = logs
        }
    }
    
    func add(log: String) {
        self.logs.removeAll { $0 == log }
        self.logs.append(log)
        if self.logs.count > MAX_SAVE_COUNT {
            self.logs = Array(self.logs.dropFirst(self.logs.count - MAX_SAVE_COUNT))
        }
        
        UserDefaultCache.save(array: logs, forKey: .recentSearch)
    }
    
    func getLogs() -> [String] {
        return self.logs.reversed()
    }
    
    func removeAll() {
        self.logs.removeAll()
        UserDefaultCache.save(array: logs, forKey: .recentSearch)
    }
}
