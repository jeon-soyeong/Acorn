//
//  UIImageView+Acorn.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/09.
//

import Foundation
import UIKit

extension UIImageView {
    public func setImage(with url: String) {
        let imageCacheManager = ImageCacheManager.shared
        
        if let cachedData = imageCacheManager.readCachedImageData(key: url) {
            self.image = UIImage(data: cachedData.imageData)
        }
    }
}
