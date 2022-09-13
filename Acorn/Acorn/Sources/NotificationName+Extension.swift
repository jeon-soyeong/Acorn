//
//  NotificationName+Extension.swift
//  Acorn
//
//  Created by 전소영 on 2022/09/10.
//

import Foundation
import UIKit

public extension Notification.Name {
    static let didReceiveMemoryWarning = UIApplication.didReceiveMemoryWarningNotification
    static let willTerminate = UIApplication.willTerminateNotification
    static let didEnterBackground = UIApplication.didEnterBackgroundNotification
}
