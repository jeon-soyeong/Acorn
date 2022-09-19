//
//  MemoryCache.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/12.
//

import Foundation

public class MemoryCache {
    private let cache = NSCache<NSString, CachedImage>()
    
    init() {
        cache.totalCostLimit = CacheConstants.maximumMemoryBytes
    }
    
    func configure(maximumMemoryBytes: Int) {
        cache.totalCostLimit = maximumMemoryBytes
    }

    func read(with key: String) -> CachedImage? {
        let key = NSString(string: key)
        return self.cache.object(forKey: key)
    }

    func save(data: CachedImage, with key: String) {
        let key = NSString(string: key)
        self.cache.setObject(data, forKey: key, cost: data.imageData.count)
    }

    func clearMemoryCache() {
        cache.removeAllObjects()
    }
}
