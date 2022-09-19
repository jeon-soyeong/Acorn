//
//  UIButton+Extension.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/09.
//

import Foundation
import UIKit

extension UIButton {
    @discardableResult
    public func setImage(with url: String?, placeholder: UIImage? = nil) -> URLSessionDataTask? {
        let acornManager = AcornManager.shared
        var dataTask: URLSessionDataTask?

        guard let url = url else {
            self.setImage(placeholder, for: .normal)
            return nil
        }

        guard let cachedData = acornManager.readCachedImageData(key: url) else {
            self.setImage(placeholder, for: .normal)
            dataTask = acornManager.downloadImageData(key: url) { [weak self] cachedData in
                DispatchQueue.main.async {
                    if let cachedImageData = cachedData?.imageData {
                        self?.setImage(UIImage(data: cachedImageData), for: .normal)
                    }
                }
            }
            return dataTask
        }
        self.setImage(UIImage(data: cachedData.imageData), for: .normal)
        return dataTask
    }
}
