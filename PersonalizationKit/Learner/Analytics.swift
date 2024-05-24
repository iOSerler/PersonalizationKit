//
//  Analytics.swift
//  adab
//
//  Created by Daniya on 14/01/2021.
//  Copyright © 2021 nurios. All rights reserved.
//

import Foundation

public class Analytics: NSObject {
    
    /// set it before using the singleton
    public static var staticStorage: LearnerStorage! = nil {
        didSet {
            shared = Analytics(learnerStorage: staticStorage)
        }
    }

    public static var shared = Analytics(learnerStorage: staticStorage)
    
    private init(learnerStorage: LearnerStorage) {
        self.learnerStorage = learnerStorage
    }
    
    private let learnerStorage: LearnerStorage
        
    private let launchCountKey = "launch_count"
    private let oldKey = "appOpenedCount"
    
    public var launchCount: Int {
        
        if let count = learnerStorage.retrieve(forKey: launchCountKey) as? Int {
            return count
        } else if let oldCount = learnerStorage.retrieve(forKey: oldKey) as? Int {
            return oldCount
        } else {
            return 0
        }
    }
    
    public func incrementLaunchCount() {
        var incrementedLauchCount = launchCount + 1
        learnerStorage.store(incrementedLauchCount, forKey: launchCountKey)
        logActivity("launch", type: "action", value: Double(incrementedLauchCount), startDate: Date())
        setUserProperty(launchCountKey, value: String(launchCount))
    }
    
    
    public func logActivity(_ activityId: String, type: String, value: Double?, startDate: Date) {
        
        print("log:", type, "->", activityId, "->", value ?? "nil", "| startDate:", startDate)
        
        if #available(iOS 13, *) {
            if let activityLog = ActivityLog(activityId: activityId, type: type, value: value, startDate: startDate, appVersion: learnerStorage.currentAppVersion) {
                ActivityService.shared.logActivityToHistory(activityLog)
            }
        }
    }
    
    public func setUserProperty(_ property: String, value: Any) {
        print("setUserProperty:", property, "| value:", "\(value)")
        
        if #available(iOS 13.0, *) {
            LocalLearner.shared.setProperty("\(value)", forKey: property)
        }
        
        
    }
    
}
