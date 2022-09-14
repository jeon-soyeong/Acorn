//
//  DebugPrint.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/14.
//

import Foundation

func debugPrint(_ content: String) {
    guard ImageCacheManager.shared.debugMode else { return }
    #if DEBUG
    print("[ACORN][DEBUG] \(content)")
    #endif
}
