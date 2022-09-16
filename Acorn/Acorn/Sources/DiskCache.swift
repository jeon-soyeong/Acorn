//
//  DiskCache.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/12.
//

import Foundation

public class DiskCache {
    private var fileDirectoryURL: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("cache")
    }
    private var expiration: CacheExpiration
    private(set) var maximumDiskBytes: Int

    init(maximumDiskBytes: Int, expiration: CacheExpiration) {
        self.maximumDiskBytes = maximumDiskBytes
        self.expiration = expiration
        createFileDirectory()
    }
}

// MARK: public
public extension DiskCache {
    func read(with key: String) -> CachedImage? {
        guard let fileURL = getFileURL(key: key) else {
            debugPrint(ImageCacheError.invalidFileURL.description)
            return nil
        }
        
        guard let imageData = try? Data(contentsOf: fileURL) else {
            debugPrint(ImageCacheError.failedReadDataFromDisk.description)
            return nil
        }
        
        return CachedImage(imageData: imageData)
    }

    func save(data: CachedImage, with key: String) {
        guard let fileURL = getFileURL(key: key) else {
            debugPrint(ImageCacheError.invalidFileURL.description)
            return
        }
        do {
            try data.imageData.write(to: fileURL)
            try setFileAttributes(fileURL: fileURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func hit(with key: String) {
        do {
            guard let fileURL = getFileURL(key: key) else {
                debugPrint(ImageCacheError.invalidFileURL.description)
                return
            }
            try setFileAttributes(fileURL: fileURL)
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func setFileAttributes(fileURL: URL) throws {
        let now = Date()
        let attributes: [FileAttributeKey: Any] = [
            .modificationDate: now.fileDate
        ]
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: fileURL.path)
        } catch {
            throw error
        }
    }

    func getAllFileURLs(key: [URLResourceKey]) throws -> [URL] {
        guard let fileDirectoryURL = self.fileDirectoryURL else {
            throw ImageCacheError.invalidFileDirectoryURL
        }
    
        guard let directoryEnumerator = FileManager.default.enumerator(at: fileDirectoryURL,
                                                                       includingPropertiesForKeys: key,
                                                                       options: .skipsHiddenFiles) else {
            throw ImageCacheError.failedCreateFileEnumerator
        }

        guard let urls = directoryEnumerator.allObjects as? [URL] else {
            throw ImageCacheError.invalidFileEnumeratorContents
        }
        return urls
    }

    func getFileModificationDate(fileURL: URL) throws -> Date {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            guard let modificationDate = attributes[.modificationDate] as? Date else {
                throw ImageCacheError.failedGetFileModificationDate
            }
            
            return modificationDate
        } catch {
           throw error
        }
    }

    func getTotalDiskCacheSize() -> Int {
        let key: [URLResourceKey] = [.fileSizeKey]
        guard let urls = try? getAllFileURLs(key: key) else {
            return 0
        }
        
        let totalSize = urls.reduce(0) { size, url in
            let resourceValues = try? url.resourceValues(forKeys: Set(key))
            let fileSize = resourceValues?.fileSize ?? 0
            return size + fileSize
        }
        return totalSize
    }

    func removeUnnecessaryCache() {
        do {
            try removeExpiredCache()
            try removeOverSizeCache()
        } catch {
            if let error = error as? ImageCacheError {
                debugPrint(error.description)
            } else {
                debugPrint(error.localizedDescription)
            }
        }
    }

    func removeExpiredCache() throws {
        let urlResourceKeys: [URLResourceKey] = [.isDirectoryKey,
                                                 .contentModificationDateKey]
        do {
            let urls = try getAllFileURLs(key: urlResourceKeys)
            let keys = Set(urlResourceKeys)
            let expiredFiles = getExpiredFiles(urls: urls, keys: keys)

            expiredFiles.forEach { url in
                removeFile(at: url)
            }
        } catch {
            throw error
        }
    }

    func removeOverSizeCache() throws {
        let urlResourceKeys: [URLResourceKey] = [.isDirectoryKey,
                                                 .contentModificationDateKey,
                                                 .fileSizeKey]
        do {
            let urls = try getAllFileURLs(key: urlResourceKeys)
            let keys = Set(urlResourceKeys)
            try removeDiskCacheUntilTargetSize(urls: urls, keys: keys)
        } catch {
            throw error
        }
    }

    func clearDiskCache() {
        if let fileDirectoryURL = self.fileDirectoryURL {
            removeFile(at: fileDirectoryURL)
        }
        self.createFileDirectory()
    }
}

// MARK: private
private extension DiskCache {
    func createFileDirectory() {
        guard let fileDirectoryURL = self.fileDirectoryURL else {
            debugPrint(ImageCacheError.invalidFileDirectoryURL.description)
            return
        }
        if FileManager.default.fileExists(atPath: fileDirectoryURL.path) { return }
        try? FileManager.default.createDirectory(atPath: fileDirectoryURL.path,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
    }

    func getFileURL(key: String) -> URL? {
        guard let fileName = key.components(separatedBy: "/").last else {
            debugPrint(ImageCacheError.invalidFileName.description)
            return nil
        }
        guard let fileDirectoryURL = self.fileDirectoryURL else {
            debugPrint(ImageCacheError.invalidFileDirectoryURL.description)
            return nil
        }
    
        return fileDirectoryURL.appendingPathComponent(fileName)
    }

    func getExpiredFiles(urls: [URL], keys: Set<URLResourceKey>) -> [URL] {
        let now = Date()

        let expiredURLs = urls.filter { fileURL in
            let resourceValues = try? fileURL.resourceValues(forKeys: keys)
            let isDirectory = resourceValues?.isDirectory ?? false
            if isDirectory {
                return false
            }
            var isExpired: Bool = true
            if let contentModificationDate = resourceValues?.contentModificationDate {
                let expirationDate = expiration.calculateExpirationDate(from: contentModificationDate)
                isExpired = expirationDate.isPast(from: now)
            }
            return isExpired
        }
        return expiredURLs
    }

    func sortURLsByContentModificationDate(urls: [URL], keys: Set<URLResourceKey>) throws -> [URL] {
        let sortedUrls = try urls.sorted(by: {
            let resourceValuesForLhs = try $0.resourceValues(forKeys: keys)
            let resourceValuesForRhs = try $1.resourceValues(forKeys: keys)
            guard let contentModificationDateForLhs = resourceValuesForLhs.contentModificationDate,
                  let contentModificationDateForRhs = resourceValuesForRhs.contentModificationDate else {
                      throw ImageCacheError.failedSortedArray
                  }
            return contentModificationDateForLhs > contentModificationDateForRhs
        })
        return sortedUrls
    }

    func removeDiskCacheUntilTargetSize(urls: [URL], keys: Set<URLResourceKey>) throws {
        do {
            let targetSize = maximumDiskBytes / 2
            var totalSize = getTotalDiskCacheSize()
            var sortURLsByContentModificationDate = try sortURLsByContentModificationDate(urls: urls, keys: keys)
            
            while totalSize > targetSize, let lastURL = sortURLsByContentModificationDate.popLast() {
                if let fileSize = try? lastURL.resourceValues(forKeys: keys).fileSize {
                    totalSize -= fileSize
                    removeFile(at: lastURL)
                }
            }
        } catch {
            throw error
        }
    }

    func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
