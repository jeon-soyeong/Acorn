//
//  ImageCacheManager.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/08.
//

import Foundation
import UIKit

public class ImageCacheManager {
    public static let shared = ImageCacheManager()
    private var memoryCache: MemoryCache?
    private var diskCache: DiskCache?
    private var dataTask: URLSessionDataTask?

    public var debugMode: Bool = true

    private init() {
        setupNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didReceiveMemoryWarning, object: nil)
        NotificationCenter.default.removeObserver(self, name: .willTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEnterBackground, object: nil)
    }
}

// MARK: public
public extension ImageCacheManager {
    func configureCache(maximumMemoryBytes: Int? = CacheConstants.maximumMemoryBytes,
                               maximumDiskBytes: Int? = CacheConstants.maximumDiskBytes,
                               expiration: CacheExpiration? = .days(10)) {
        if let maximumMemoryBytes = maximumMemoryBytes,
           let maximumDiskBytes = maximumDiskBytes,
           let expiration = expiration {
            memoryCache = MemoryCache(maximumMemoryBytes: maximumMemoryBytes)
            diskCache = DiskCache(maximumDiskBytes: maximumDiskBytes, expiration: expiration)
        }
        
        //TODO: Test 후 삭제
//        clearDiskCache()
//        print("clearDiskCache")
    }

    func readCachedImageData(key: String) -> CachedImage? {
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

    func downloadImageData(key: String, completionHandler: @escaping (CachedImage?) -> Void) -> URLSessionDataTask? {
        let dataTask = downloadImageData(url: key) { downloadImageData in
           guard let downloadImageData = downloadImageData else {
               debugPrint(ImageCacheError.failedDownloadImageData.description)
               return
           }
           print("downloadImageData: \(downloadImageData.imageData)")
           completionHandler(downloadImageData)
        }

        return dataTask
    }

    func cancelImageDownloadTask() {
        dataTask?.cancel()
        dataTask = nil
    }
    
    @objc func clearMemoryCache() {
        memoryCache?.clearMemoryCache()
    }

    @objc func clearDiskCache() {
        diskCache?.clearDiskCache()
    }
    
    @objc func removeOldDiskCache() {
        diskCache?.removeOldCache()
    }
}

// MARK: private
private extension ImageCacheManager {
    func readMemoryCachedImageData(with key: String) -> CachedImage? {
        return memoryCache?.read(with: key)
    }

    func readDiskCachedImageData(with key: String) -> CachedImage? {
        let cachedImage = diskCache?.read(with: key)
        if let cachedImage = cachedImage {
            memoryCache?.save(data: cachedImage, with: key)
        }
        return cachedImage
    }

    func saveMemoryCachedImageData(data: CachedImage, with key: String) {
        print("saveMemoryCachedImageData")
        memoryCache?.save(data: data, with: key)
    }

    func saveDiskCachedImageData(data: CachedImage, with key: String) {
        print("saveDiskCachedImageData")
        diskCache?.save(data: data, with: key)
    }

    func downloadImageData(url: String, completionHandler: @escaping (CachedImage?) -> Void) -> URLSessionDataTask? {
        if let imageUrl = URL(string: url) {
            dataTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] (data, response, error) in
                guard let data = data else {
                    debugPrint(ImageCacheError.failedData.description)
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

    func setupNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(clearMemoryCache), name: .didReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOldDiskCache), name: .willTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOldDiskCache), name: .didEnterBackground, object: nil)
    }
}
