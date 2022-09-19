//
//  AcornTests.swift
//  AcornTests
//
//  Created by 전소영 on 2022/09/08.
//

import XCTest
@testable import Acorn

class AcornTests: XCTestCase {
    let acornManager = AcornManager.shared
    let testString = "testCacheData!!!.png"
    var cacheData: CachedImage?
    var diskCache: DiskCache?

    override func setUpWithError() throws {
        acornManager.configureCache(maximumDiskBytes: 10, expiration: .seconds(1))
        diskCache = acornManager.diskCache
        diskCache?.clearDiskCache()

        guard let testData = """
        \(testString)
        """.data(using: .utf8) else {
            XCTFail()
            return
        }
        cacheData = CachedImage(imageData: testData)
    }

    func test_givenAcornManager_WhenSaveAndReadMemoryCache_ThenSuccess() throws {
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        acornManager.saveMemoryCachedImageData(data: cacheData, with: "dataKey")

        guard let result = acornManager.readMemoryCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        let resultString = String(data: result.imageData, encoding: .utf8)
        XCTAssert(resultString == testString)
    }

    func test_givenAcornManager_WhenClearMemoryCache_ThenSuccess() throws {
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        acornManager.saveMemoryCachedImageData(data: cacheData, with: "dataKey")

        guard let result = acornManager.readMemoryCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        acornManager.clearMemoryCache()
        if let dataCount = acornManager.readMemoryCachedImageData(with: "dataKey")?.imageData.count {
            XCTAssertEqual(dataCount, 0)
        }
        XCTAssertNil(acornManager.readMemoryCachedImageData(with: "dataKey")?.imageData)
    }

    func test_givenAcornManager_WhenSaveAndReadDiskCache_ThenSuccess() throws {
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        acornManager.saveDiskCachedImageData(data: cacheData, with: "dataKey")

        guard let result = acornManager.readDiskCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        let resultString = String(data: result.imageData, encoding: .utf8)
        XCTAssert(resultString == testString)
    }

    func test_givenAcornManager_WhenClearDiskCache_ThenSuccess() throws {
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        acornManager.saveDiskCachedImageData(data: cacheData, with: "dataKey")

        guard let result = acornManager.readDiskCachedImageData(with: "dataKey") else {
            XCTFail()
            return
        }
        XCTAssert(result.imageData.count == 20)

        acornManager.clearDiskCache()
        if let dataCount = acornManager.readDiskCachedImageData(with: "dataKey")?.imageData.count {
            XCTAssertEqual(dataCount, 0)
        }
        XCTAssertNil(acornManager.readDiskCachedImageData(with: "dataKey")?.imageData)
    }

    func test_givenDiskCache_WhenGetTotalDiskCacheSize_ThenSuccess() throws {
        var totalDiskCacheSize = diskCache?.getTotalDiskCacheSize()
        XCTAssertEqual(totalDiskCacheSize, 0)

        if let cacheData = cacheData {
            diskCache?.save(data: cacheData, with: "dataKey")
            totalDiskCacheSize = diskCache?.getTotalDiskCacheSize()
            XCTAssertEqual(totalDiskCacheSize, 20)
        } else {
            XCTFail()
        }
    }

    func test_givenDiskCache_WhenCacheHit_ThenSuccess() {
        let expectation = expectation(description: #function)
        
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        let key = "dataKey"
        diskCache?.save(data: cacheData, with: key)

        do {
            let urlResourceKeys: [URLResourceKey] = [.contentModificationDateKey]
            let urls = try self.diskCache?.getAllFileURLs(key: urlResourceKeys)
            
            guard let fileURL = urls?.first,
                  let modificationDate = try self.diskCache?.getFileModificationDate(fileURL: fileURL) else {
                      XCTFail()
                      return
                  }

            delay(1.0) {
                self.diskCache?.read(with: key)
                
                guard let modificationDate2 = try? self.diskCache?.getFileModificationDate(fileURL: fileURL) else {
                    XCTFail()
                    return
                }
                XCTAssertTrue(modificationDate < modificationDate2)
                expectation.fulfill()
            }
        } catch {
            if let error = error as? ImageCacheError {
                debugPrint(error.description)
            } else {
                debugPrint(error.localizedDescription)
            }
            XCTFail()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_givenDiskCache_WhenRemoveExpiredCache_ThenSuccess() {
        let expectation = expectation(description: #function)

        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        diskCache?.save(data: cacheData, with: "dataKey")

        delay(2.0) {
            try? self.diskCache?.removeExpiredCache()
            XCTAssertNil(self.diskCache?.read(with: "dataKey"))
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 10.0)
    }

    func test_givenDiskCache_WhenRemoveOverSizeCache_ThenSuccess() {
        guard let cacheData = cacheData else {
            XCTFail()
            return
        }
        diskCache?.save(data: cacheData, with: "dataKey")

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
