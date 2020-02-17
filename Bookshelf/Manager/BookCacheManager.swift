//
//  BookCacheManager.swift
//  Bookshelf
//
//  Created by Kyungwon Kang on 2020/02/17.
//  Copyright © 2020 Kyungwon Kang. All rights reserved.
//

import UIKit

class BookCacheManager {
    static let shared = BookCacheManager()
    private (set) var images = NSCache<NSString, UIImage>()
    
    func getImageFromURL(urlString: String, completion: @escaping (UIImage) -> Void) -> URLSessionDataTask? {
        guard let url = URL(string: urlString) else {
            return nil
        }

        if let image = images.object(forKey: urlString as NSString) {
            completion(image)
            return nil
        }
        
        let task = URLSessionManager.getImageData(url: url) { [weak self, urlString] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    self.images.setObject(image, forKey: urlString as NSString)
                    completion(image)
                }
            case .failure(_):
                break
            }
        }
        return task
    }

}
