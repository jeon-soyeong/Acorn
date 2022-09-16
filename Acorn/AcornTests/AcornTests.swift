//
//  AcornTests.swift
//  AcornTests
//
//  Created by 전소영 on 2022/09/08.
//

import XCTest
@testable import Acorn

class AcornTests: XCTestCase {
    let imageCacheManager = ImageCacheManager.shared
    let testString = "testCacheData!!!.png"
    var cacheData: CachedImage?
    var diskCache: DiskCache?

    override func setUpWithError() throws {
        ImageCacheManager.shared.configureCache(maximumDiskBytes: 10, expiration: .seconds(1))
        diskCache = imageCacheManager.diskCache
        diskCache?.clearDiskCache()

        guard let testData = """
        \(testString)
        """.data(using: .utf8) else {
            XCTFail()
            return
        }
        cacheData = CachedImage(imageData: testData)
    }

    func test_givenImageCacheManager_WhenSaveAndReadMemoryCache_ThenSuccess() throws {
        if let cacheData = cacheData {
            imageCacheManager.saveMemoryCachedImageData(data: cacheData, with: "dataKey")
        }

        guard let result = imageCacheManager.readMemoryCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        let resultString = String(data: result.imageData, encoding: .utf8)
        XCTAssert(resultString == testString)
    }

    func test_givenImageCacheManager_WhenClearMemoryCache_ThenSuccess() throws {
        if let cacheData = cacheData {
            imageCacheManager.saveMemoryCachedImageData(data: cacheData, with: "dataKey")
        }

        guard let result = imageCacheManager.readMemoryCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        imageCacheManager.clearMemoryCache()
        if let dataCount = imageCacheManager.readMemoryCachedImageData(with: "dataKey")?.imageData.count {
            XCTAssertEqual(dataCount, 0)
        }
        XCTAssertNil(imageCacheManager.readMemoryCachedImageData(with: "dataKey")?.imageData)
    }

    func test_givenImageCacheManager_WhenSaveAndReadDiskCache_ThenSuccess() throws {
        if let cacheData = cacheData {
            imageCacheManager.saveDiskCachedImageData(data: cacheData, with: "dataKey")
        }

        guard let result = imageCacheManager.readDiskCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        let resultString = String(data: result.imageData, encoding: .utf8)
        XCTAssert(resultString == testString)
    }

    func test_givenImageCacheManager_WhenClearDiskCache_ThenSuccess() throws {
        if let cacheData = cacheData {
            imageCacheManager.saveDiskCachedImageData(data: cacheData, with: "dataKey")
        }

        guard let result = imageCacheManager.readDiskCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        imageCacheManager.clearDiskCache()
        if let dataCount = imageCacheManager.readDiskCachedImageData(with: "dataKey")?.imageData.count {
            XCTAssertEqual(dataCount, 0)
        }
        XCTAssertNil(imageCacheManager.readDiskCachedImageData(with: "dataKey")?.imageData)
    }

    func test_givenDiskCache_WhenGetTotalDiskCacheSize_ThenSuccess() throws {
        var totalDiskCacheSize = diskCache?.getTotalDiskCacheSize()
        XCTAssertEqual(totalDiskCacheSize, 0)

        if let cacheData = cacheData {
            diskCache?.save(data: cacheData, with: "dataKey")
            totalDiskCacheSize = diskCache?.getTotalDiskCacheSize()
            XCTAssertEqual(totalDiskCacheSize, 20)
        }
    }

    func test_givenDiskCache_WhenCacheHit_ThenSuccess() {
        let expectation = expectation(description: #function)
        
        let key = "dataKey"
        if let cacheData = cacheData {
            diskCache?.save(data: cacheData, with: key)
        }
        
        delay(2) {
            do {
                let urlResourceKeys: [URLResourceKey] = [.contentModificationDateKey]
                let urls = try self.diskCache?.getAllFileURLs(key: urlResourceKeys)
                
                guard let cachedData = self.diskCache?.read(with: key),
                      let fileURL = urls?.first,
                      let modificationDate = try self.diskCache?.getFileModificationDate(fileURL: fileURL) else {
                    XCTFail()
                    return
                }
                self.diskCache?.hit(with: key)
   
                guard let modificationDate2 = try self.diskCache?.getFileModificationDate(fileURL: fileURL) else {
                    XCTFail()
                    return
                }
                XCTAssertTrue(modificationDate < modificationDate2)
                expectation.fulfill()
            }
            catch {
                if let error = error as? ImageCacheError {
                    debugPrint(error.description)
                } else {
                    debugPrint(error.localizedDescription)
                }
            }
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_givenDiskCache_WhenRemoveExpiredCache_ThenSuccess() {
        let expectation = expectation(description: #function)

        if let cacheData = cacheData {
            diskCache?.save(data: cacheData, with: "dataKey")
        }
        delay(2.0) {
            try? self.diskCache?.removeExpiredCache()
            XCTAssertNil(self.diskCache?.read(with: "dataKey"))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_givenDiskCache_WhenRemoveOverSizeCache_ThenSuccess() {
        if let cacheData = cacheData {
            diskCache?.save(data: cacheData, with: "dataKey")
        }

        let testString2 = ".png"
        guard let testData2 = """
        \(testString2)
        """.data(using: .utf8) else {
            XCTFail()
            return
        }
        let data2 = CachedImage(imageData: testData2)
        diskCache?.save(data: data2, with: "dataKey2")

        XCTAssertEqual(diskCache?.getTotalDiskCacheSize(), 24)
        try? diskCache?.removeOverSizeCache()
        XCTAssertEqual(diskCache?.getTotalDiskCacheSize(), 4)
        
        if let diskCacheTotalSize = diskCache?.getTotalDiskCacheSize(),
           let diskCacheMaximumDiskBytes = diskCache?.maximumDiskBytes {
            XCTAssertTrue(diskCacheTotalSize < diskCacheMaximumDiskBytes)
        }
    }
}
