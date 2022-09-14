//
//  CacheExpiration.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/13.
//

import Foundation

public enum CacheExpiration {
    case seconds(TimeInterval)
    case days(Int)
    case date(Date)
    
    func calculateExpirationDate(from date: Date) -> Date {
        switch self {
        case .seconds(let seconds):
            return date.addingTimeInterval(seconds)
        case .days(let days):
            let secondsInOneDay = TimeInterval(60 * 60 * 24) * TimeInterval(days)
            return date.addingTimeInterval(secondsInOneDay)
        case .date(let date):
            return date
        }
    }
}
