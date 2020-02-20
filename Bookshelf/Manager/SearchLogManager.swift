//
//  RecentSearchManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/20.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import Foundation

class SearchLogManager {
    private(set) var searched: [String] = []
    private let maxSaveCount = 5
    
    init() {
        if let searchedTexts = RECENTLY_SEARCHED_TEXTS.getStringArray() {
            self.searched = searchedTexts
        }
    }
    
    func searched(searchedText: String) {
        self.searched.removeAll { $0 == searchedText }
        self.searched.append(searchedText)
        if self.searched.count > maxSaveCount {
            self.searched = Array(self.searched.dropFirst(self.searched.count - maxSaveCount))
        }
        
        RECENTLY_SEARCHED_TEXTS.save(array: self.searched)
    }
    
    func removeAll() {
        self.searched.removeAll()
        RECENTLY_SEARCHED_TEXTS.save(array: nil)
    }
}
