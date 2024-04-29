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
    public static var initialStaticStorage: LearnerStorage! = nil {
        didSet {
            shared = Analytics(learnerStorage: initialStaticStorage)
        }
    }

    public static var shared = Analytics(learnerStorage: initialStaticStorage)
    
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
        setUserProperty(LearnerProperties.appOpenCount.rawValue, value: String(launchCount))
    }
    
    
    public func logActivity(_ activityId: String, type: String, value: Double?, startDate: Date) {
        
        print("engagement:", activityId, "| type:", type, "| value:", value ?? 0, "| startDate:", startDate)
        
        if #available(iOS 13, *) {
            if let engagement = Engagement(activityId: activityId, type: type, value: value, startDate: startDate) {
                EngagementService.shared.addEngagementToHistory(engagement)
            }
        }
    }
    
    public func setUserProperty(_ property: String, value: Any) {
        print("setUserProperty:", property, "| value:", "\(value)")
        
        if #available(iOS 13.0, *) {
            switch property {
            case LearnerProperties.gender.rawValue, LearnerProperties.language.rawValue, LearnerProperties.countryCode.rawValue, LearnerProperties.ageRange.rawValue, LearnerProperties.marketingSource.rawValue, LearnerProperties.knowledgeLevel.rawValue, LearnerProperties.motivation.rawValue:
                LocalLearner.shared.updateLocalLearner()
            default:
                LocalLearner.shared.setProperty("\(value)", forKey: property)
            }
        }
        
        
    }
    
}
