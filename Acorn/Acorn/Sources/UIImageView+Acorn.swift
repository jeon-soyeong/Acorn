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
        
        imageCacheManager.readCachedImageData(key: url) { [weak self] cachedData in
            DispatchQueue.main.async {
                if let cachedImageData = cachedData?.imageData {
                    self?.image = UIImage(data: cachedImageData)
                }
            }
        }
    }
}
