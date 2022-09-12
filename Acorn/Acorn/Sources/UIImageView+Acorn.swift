//
//  UIImageView+Acorn.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/09.
//

import Foundation
import UIKit

extension UIImageView {
    @discardableResult
    public func setImage(with url: String?, placeholder: UIImage? = nil) -> URLSessionDataTask? {
        let imageCacheManager = ImageCacheManager.shared
        var dataTask: URLSessionDataTask?

        guard let url = url else {
            self.image = placeholder
            return nil
        }
        
        guard let cachedData = imageCacheManager.readCachedImageData(key: url) else {
            self.image = placeholder
            dataTask = imageCacheManager.downloadImageData(key: url) { [weak self] cachedData in
                DispatchQueue.main.async {
                    print("downloadImage complete")
                    if let cachedImageData = cachedData?.imageData {
                        self?.image = UIImage(data: cachedImageData)
                    }
                }
            }
            return dataTask
        }
        self.image = UIImage(data: cachedData.imageData)
        return dataTask
    }
}
