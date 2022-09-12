//
//  DiskCache.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/12.
//

import Foundation

class DiskCache {
    public static let shared = DiskCache()
    
    private var fileDirectoryURL: URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?.appendingPathComponent("cache")
    }
    
    init() {
        createFileDirectory()
    }
    
    func read(with key: String) -> CachedImage? {
        guard let fileURL = getFileURL(key: key) else {
            print(ImageCacheError.invalidFileURL.description)
            return nil
        }
        guard let imageData = try? Data(contentsOf: fileURL) else {
            print(ImageCacheError.failedReadDataFromDisk.description)
            return nil
        }
        return CachedImage(imageData: imageData)
    }
    
    func save(data: CachedImage, with key: String) {
        guard let fileURL = getFileURL(key: key) else {
            print(ImageCacheError.invalidFileURL.description)
            return
        }
        do {
            try data.imageData.write(to: fileURL)
        } catch {
            print(ImageCacheError.failedSaveDataToDisk.description)
            return
        }
    }
   
    func clearDiskCache() {
        if let fileDirectoryURL = self.fileDirectoryURL {
            try? FileManager.default.removeItem(at: fileDirectoryURL)
        }
        self.createFileDirectory()
    }
    
    private func createFileDirectory() {
        guard let fileDirectoryURL = self.fileDirectoryURL else {
            print(ImageCacheError.invalidFileDirectoryURL.description)
            return
        }
        if FileManager.default.fileExists(atPath: fileDirectoryURL.path) { return }
        try? FileManager.default.createDirectory(atPath: fileDirectoryURL.path, withIntermediateDirectories: true, attributes: nil)
    }
    
    private func getFileURL(key: String) -> URL? {
        guard let fileName = key.components(separatedBy: "/").last else {
            print(ImageCacheError.invalidFileName.description)
            return nil
        }
        guard let fileDirectoryURL = self.fileDirectoryURL else {
            print(ImageCacheError.invalidFileDirectoryURL.description)
            return nil
        }
        return fileDirectoryURL.appendingPathComponent(fileName)
    }
}
