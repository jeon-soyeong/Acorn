//
//  ImageCacheManager.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/08.
//

import Foundation
import UIKit

public class ImageCacheManager: NSObject {
    public static let shared = ImageCacheManager()
    private let memoryCache = MemoryCache.shared
    private let diskCache = DiskCache.shared
    var dataTask: URLSessionDataTask?

    override init() {
        super.init()
        setupNotification()
    }

    deinit {
        //TODO: // background, diskWarning 추가
        NotificationCenter.default.removeObserver(self, name: .memoryWarning, object: nil)
    }

    public func readCachedImageData(key: String) -> CachedImage? {
        guard let memoryCachedImageData = readMemoryCachedImageData(with: key) else {
            guard let diskCachedImageData = readDiskCachedImageData(with: key) else {
                return nil
            }
            print("disk!!")
            return diskCachedImageData
        }
        print("momory!!")
        return memoryCachedImageData
    }

    public func downloadImageData(key: String, completionHandler: @escaping (CachedImage?) -> Void) -> URLSessionDataTask? {
        let dataTask = downloadImageData(url: key) { downloadImageData in
           guard let downloadImageData = downloadImageData else {
               print(ImageCacheError.failedDownloadImageData.description)
               return
           }
           print("downloadImageData: \(downloadImageData.imageData)")
           completionHandler(downloadImageData)
        }

        return dataTask
    }

    public func configureCacheMemory() {
        memoryCache.configureCacheMemory()
    }

    public func cancelImageDownloadTask() {
        dataTask?.cancel()
        dataTask = nil
    }

    private func readMemoryCachedImageData(with key: String) -> CachedImage? {
        return memoryCache.read(with: key)
    }

    private func readDiskCachedImageData(with key: String) -> CachedImage? {
        let cachedImage = diskCache.read(with: key)
        if let cachedImage = cachedImage {
            memoryCache.save(data: cachedImage, with: key)
        }
        return cachedImage
    }

    private func saveMemoryCachedImageData(data: CachedImage, with key: String) {
        print("saveMemoryCachedImageData")
        memoryCache.save(data: data, with: key)
    }

    private func saveDiskCachedImageData(data: CachedImage, with key: String) {
        print("saveDiskCachedImageData")
        diskCache.save(data: data, with: key)
    }

    private func downloadImageData(url: String, completionHandler: @escaping (CachedImage?) -> Void) -> URLSessionDataTask? {
        if let imageUrl = URL(string: url) {
            dataTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                guard let data = data else {
                    print(ImageCacheError.failedData.description)
                    return
                }
                self?.saveMemoryCachedImageData(data: CachedImage(imageData: data), with: url)
                self?.saveDiskCachedImageData(data: CachedImage(imageData: data), with: url)
                completionHandler(CachedImage(imageData: data))
            }
            dataTask?.resume()
        }
        return dataTask
    }

    private func setupNotification() {
        //TODO: // background, diskWarning 추가
        NotificationCenter.default.addObserver(self, selector: #selector(clearMemoryCache), name: .memoryWarning, object: nil)
    }

    @objc private func clearMemoryCache() {
        MemoryCache.shared.clearMemoryCache()
    }

    @objc private func clearDiskCache() {
        DiskCache.shared.clearDiskCache()
    }
}
