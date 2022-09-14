//
//  TestHelper.swift
//  AcornDemoTests
//
//  Created by 전소영 on 2022/09/14.
//

import Foundation

func delay(_ time: Double, block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + time) { block() }
}
