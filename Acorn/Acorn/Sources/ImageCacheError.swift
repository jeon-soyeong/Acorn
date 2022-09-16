//
//  ImageCacheError.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/12.
//

import Foundation

public enum ImageCacheError: Error {
    case invalidFileName
    case invalidFileDirectoryURL
    case invalidFileURL
    case invalidFileEnumeratorContents
    case failedData
    case failedDownloadImageData
    case failedSaveDataToDisk
    case failedReadDataFromDisk
    case failedSetCacheFileAttribute
    case failedCreateFileEnumerator
    case failedSortedArray
    case failedGetFileModificationDate

    var description: String {
        switch self {
        case .invalidFileName:
            return "invalid fileName"
        case .invalidFileDirectoryURL:
            return "invalid fileDirectoryURL"
        case .invalidFileURL:
            return "invalid fileURL"
        case .invalidFileEnumeratorContents:
            return "invalid fileEnumeratorContents"
        case .failedData:
            return "fail to handle data"
        case .failedDownloadImageData:
            return "fail to download imageData"
        case .failedSaveDataToDisk:
            return "fail to save data"
        case .failedReadDataFromDisk:
            return "fail to read data"
        case .failedSetCacheFileAttribute:
            return "fail to set cacheFileAttribute"
        case .failedCreateFileEnumerator:
            return "fail to create fileEnumerator"
        case .failedSortedArray:
            return "fail to sort array"
        case .failedGetFileModificationDate:
            return "fail to get fileModificationDate"
        }
    }
}
