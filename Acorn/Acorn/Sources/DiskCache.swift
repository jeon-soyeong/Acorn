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
    private var maximumDiskBytes: Int
    private var expiration: CacheExpiration

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
        } catch {
            debugPrint(ImageCacheError.failedSaveDataToDisk.description)
            return
        }
        
        let now = Date()
        let attributes: [FileAttributeKey: Any] = [
            .creationDate: now.fileDate,
            .modificationDate: expiration.calculateExpirationDate(from: now).fileDate
        ]
        do {
            try FileManager.default.setAttributes(attributes, ofItemAtPath: fileURL.path)
        } catch {
            debugPrint(ImageCacheError.failedSetCacheFileAttribute.description)
            return
        }
    }
    
    func removeOldCache() {
        let urlResourceKeys: [[URLResourceKey]] = [[
                                                        .isDirectoryKey,
                                                        .contentModificationDateKey,
                                                   ],
                                                   [
                                                        .isDirectoryKey,
                                                        .creationDateKey,
                                                        .fileSizeKey
                                                   ]]
        do {
            for i in 0..<2 {
                let urls = try getAllFileURLs(key: urlResourceKeys[i])
                let keys = Set(urlResourceKeys[i])
                if i == 0 {
                    removeExpiredCache(urls: urls, keys: keys)
                } else {
                    try removeOverSizeCache(urls: urls, keys: keys)
                }
            }
        } catch ImageCacheError.invalidFileDirectoryURL {
            debugPrint(ImageCacheError.invalidFileDirectoryURL.description)
        } catch ImageCacheError.failedCreateFileEnumerator {
            debugPrint(ImageCacheError.failedCreateFileEnumerator.description)
        } catch ImageCacheError.invalidFileEnumeratorContents {
            debugPrint(ImageCacheError.invalidFileEnumeratorContents.description)
        } catch ImageCacheError.failedSortedArray {
            debugPrint(ImageCacheError.failedSortedArray.description)
        } catch {
            debugPrint(error.localizedDescription)
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

    func removeExpiredCache(urls: [URL], keys: Set<URLResourceKey>) {
        let expiredFiles = getExpiredFiles(urls: urls, keys: keys)

        expiredFiles.forEach { url in
            removeFile(at: url)
        }
    }

    func getExpiredFiles(urls: [URL], keys: Set<URLResourceKey>) -> [URL] {
        let now = Date()

        let expiredURLs = urls.filter { fileURL in
            let resourceValues = try? fileURL.resourceValues(forKeys: keys)
            let exprirationDate = resourceValues?.contentModificationDate
            let isDirectory = resourceValues?.isDirectory ?? false
            if isDirectory {
                return false
            }
            return exprirationDate?.isPast(from: now) ?? true
        }
        return expiredURLs
    }

    func removeOverSizeCache(urls: [URL], keys: Set<URLResourceKey>) throws {
        var totalSize = getTotalDiskCacheSize(urls: urls, keys: keys)
        let targetSize = maximumDiskBytes / 2
        guard var sortURLsByCreationDate = try sortURLsByCreationDate(urls: urls, keys: keys) else {
            throw ImageCacheError.failedSortedArray
        }
        removeDiskCacheUntilTargetSize(totalSize: &totalSize, targetSize: targetSize, sortURLsByCreationDate: &sortURLsByCreationDate, keys: keys)
    }

    func getTotalDiskCacheSize(urls: [URL], keys: Set<URLResourceKey>) -> Int {
        let totalSize = urls.reduce(0) { size, url in
            let resourceValues = try? url.resourceValues(forKeys: keys)
            let fileSize = resourceValues?.fileSize ?? 0
            return size + fileSize
        }
        return totalSize
    }

    func sortURLsByCreationDate(urls: [URL], keys: Set<URLResourceKey>) throws -> [URL]? {
        let sortedUrls = try? urls.sorted(by: {
            let resourceValuesForLhs = try $0.resourceValues(forKeys: keys)
            let resourceValuesForRhs = try $1.resourceValues(forKeys: keys)
            guard let creationDateForLhs = resourceValuesForLhs.creationDate,
                  let creationDateForRhs = resourceValuesForRhs.creationDate else {
                      throw ImageCacheError.failedSortedArray
                  }
            return creationDateForLhs > creationDateForRhs
        })
        return sortedUrls
    }

    func removeDiskCacheUntilTargetSize(totalSize: inout Int, targetSize: Int, sortURLsByCreationDate: inout [URL], keys: Set<URLResourceKey>) {
        while totalSize > targetSize, let lastURL = sortURLsByCreationDate.popLast() {
            let resourceValues = try? lastURL.resourceValues(forKeys: keys)
            let fileSize = resourceValues?.fileSize ?? 0
            totalSize -= fileSize
            removeFile(at: lastURL)
        }
    }

    func removeFile(at url: URL) {
        try? FileManager.default.removeItem(at: url)
    }
}
