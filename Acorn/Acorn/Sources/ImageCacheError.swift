//
//  ImageCacheError.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/12.
//

import Foundation

enum ImageCacheError: Error {
    case invalidFileName
    case invalidFileDirectoryURL
    case invalidFileURL
    case failedData
    case failedDownloadImageData
    case failedSaveDataToDisk
    case failedReadDataFromDisk

    public var description: String {
        switch self {
        case .invalidFileName:
            return "invalid fileName"
        case .invalidFileDirectoryURL:
            return "invalid FileDirectoryURL"
        case .invalidFileURL:
            return "invalid FileURL"
        case .failedData:
            return "fail to handle Data"
        case .failedDownloadImageData:
            return "fail to download ImageData"
        case .failedSaveDataToDisk:
            return "Fail to save data"
        case .failedReadDataFromDisk:
            return "Fail to read data"
        }
    }
}
