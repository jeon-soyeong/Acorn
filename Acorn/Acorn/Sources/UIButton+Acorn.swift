//
//  UIButton+Acorn.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/09.
//

import Foundation
import UIKit

extension UIButton {
    public func setImage(with url: String) {
        let imageCacheManager = ImageCacheManager.shared
        
        if let cachedData = imageCacheManager.readCachedImageData(key: url) {
            self.setImage(UIImage(data: cachedData.imageData), for: .normal)
        }
    }
}
