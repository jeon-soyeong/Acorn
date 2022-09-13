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

    private init() {
        setupNotification()
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .didReceiveMemoryWarning, object: nil)
        NotificationCenter.default.removeObserver(self, name: .willTerminate, object: nil)
        NotificationCenter.default.removeObserver(self, name: .didEnterBackground, object: nil)
    }

    public func configureCache(maximumMemoryBytes: Int? = CacheConstants.maximumMemoryBytes, maximumDiskBytes: Int? = CacheConstants.maximumDiskBytes) {
        if let maximumMemoryBytes = maximumMemoryBytes,
           let maximumDiskBytes = maximumDiskBytes {
            memoryCache = MemoryCache(maximumMemoryBytes: maximumMemoryBytes)
            diskCache = DiskCache(maximumDiskBytes: maximumDiskBytes)
        }
        
        //TODO: Test 후 삭제
//        clearDiskCache()
//        print("clearDiskCache")
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

    public func cancelImageDownloadTask() {
        dataTask?.cancel()
        dataTask = nil
    }

    private func readMemoryCachedImageData(with key: String) -> CachedImage? {
        return memoryCache?.read(with: key)
    }

    private func readDiskCachedImageData(with key: String) -> CachedImage? {
        let cachedImage = diskCache?.read(with: key)
        if let cachedImage = cachedImage {
            memoryCache?.save(data: cachedImage, with: key)
        }
        return cachedImage
    }

    private func saveMemoryCachedImageData(data: CachedImage, with key: String) {
        print("saveMemoryCachedImageData")
        memoryCache?.save(data: data, with: key)
    }

    private func saveDiskCachedImageData(data: CachedImage, with key: String) {
        print("saveDiskCachedImageData")
        diskCache?.save(data: data, with: key)
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
        NotificationCenter.default.addObserver(self, selector: #selector(clearMemoryCache), name: .didReceiveMemoryWarning, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOldDiskCache), name: .willTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(removeOldDiskCache), name: .didEnterBackground, object: nil)
    }

    @objc private func clearMemoryCache() {
        memoryCache?.clearMemoryCache()
    }

    //TODO: 사용할지
    @objc private func clearDiskCache() {
        diskCache?.clearDiskCache()
    }

    @objc private func removeOldDiskCache() {
        diskCache?.removeExpiredValues()
        diskCache?.removeSizeExceededValues()
    }
}
