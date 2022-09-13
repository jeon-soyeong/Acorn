//
//  CacheConstants.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/13.
//

import Foundation

public struct CacheConstants {
    public static let maximumMemoryBytes = Int(ProcessInfo.processInfo.physicalMemory) / 4
    public static let maximumDiskBytes = 100 * 1024 * 1024
}
