//
//  Analytics.swift
//  adab
//
//  Created by Daniya on 14/01/2021.
//  Copyright © 2021 nurios. All rights reserved.
//

import Foundation

public class Analytics: NSObject {

    public static var shared = Analytics()
        
    private let launchCountKey = "launch_count"
    private let oldKey = "appOpenedCount"
    
    public var launchCount: Int {
        
        if let count = StorageDelegate.learnerStorage.retrieve(forKey: launchCountKey) as? Int {
            return count
        } else if let oldCount = StorageDelegate.learnerStorage.retrieve(forKey: oldKey) as? Int {
            return oldCount
        } else {
            return 0
        }
    }
    
    public func incrementLaunchCount() {
        let incrementedLauchCount = launchCount + 1
        StorageDelegate.learnerStorage.store(incrementedLauchCount, forKey: launchCountKey)
        logActivity("launch", context: "app", value: String(incrementedLauchCount), startDate: Date())
        setUserProperty(launchCountKey, value: String(launchCount))
    }
    
    
    public func logActivity(_ activityId: String, context: String, value: String?, startDate: Date) {
        #if DEBUG
        print("log:", context, "->", activityId, "->", value ?? "nil", "| startDate:", startDate)
        #endif
        
        if let activityLog = ActivityLog(activityId: activityId, type: context, value: value, startDate: startDate, buildVersion: StorageDelegate.learnerStorage.currentAppVersion) {
            ActivityService.shared.logActivityToHistory(activityLog)
        }
    }
    
    public func setUserProperty(_ property: String, value: Any) {
        #if DEBUG
        print("setUserProperty:", property, "| value:", "\(value)")
        #endif
        
        LocalLearner.shared.setProperty("\(value)", forKey: property)
    }
    
}
