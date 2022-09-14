//
//  Date+Extension.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/13.
//

import Foundation

extension Date {
    var fileDate: Date {
        return Date(timeIntervalSince1970: ceil(timeIntervalSince1970))
    }

    func isPast(from date: Date) -> Bool {
        return timeIntervalSince(date) <= 0
    }
}
