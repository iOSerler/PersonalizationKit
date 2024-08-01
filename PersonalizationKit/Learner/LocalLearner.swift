//
//  LocalLearner.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 09.08.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

@available(iOS 10.0, *)
public class LocalLearner {

    public static var shared = LocalLearner()    
    
    public var learner: Learner?

    private let userDefaultsKey = "current_learner"
    private var lastLearnerUpdateAttempt: Date?
    
    public func kickstartLocalLearner(predefinedAnalyticsId: UUID? = nil, learnerPropertyKeys: [String]) {
                
        if let localLearner = retrieveLocalLearner() {
            self.learner = localLearner
            if let predefinedAnalyticsId {
                self.learner?.id = predefinedAnalyticsId
            }
        } else if let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.learner = Learner(id: predefinedAnalyticsId ?? UUID())
            StorageDelegate.learnerStorage.store(appBuildVersion, forKey: "bundleVersionAtInstall")
            learnerPropertyKeys.forEach { key in
                if let value = StorageDelegate.learnerStorage.retrieve(forKey: key) as? String {
                    self.learner?.properties[key] = value
                }
            }
        } else {
            print(#function, "error creating a learner")
        }
        
        saveLocalLearner()
        
    }
    
    public func getProperty(_ key: String) -> String? {
        self.learner?.properties[key]
    }
    
    public func setProperty(_ value: String, forKey key: String) {
        self.learner?.properties[key] = value
        saveLocalLearner()
    }
    
    /// save local => update remote
    
    private func saveLocalLearner() {
        
        guard let learner = self.learner else {
            // the current learner is nil
            return
        }
        
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(learner)
            StorageDelegate.learnerStorage.store(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding learner: \(error)")
        }
        
        guard #available(iOS 15.0, *) else {
            return
        }
        
        // FIXME: how much time is 60, i.e. seconds or minutes?
        if let lastTime = lastLearnerUpdateAttempt,
           Date().timeIntervalSince(lastTime) < 60 {
            return
        }
        
        
        if LearnerService.shared.remoteLearner != nil {
            lastLearnerUpdateAttempt = Date()
            Task {
                do {
                    LearnerService.shared.remoteLearner = try await LearnerService.shared.updateRemoteLearner()
                } catch {
                    print(#function, "error updating remote learner: \(error.localizedDescription)")
                }
            }
        }
        
        
        
    }
    
    private func retrieveLocalLearner() -> Learner? {
        guard let learnerData = StorageDelegate.learnerStorage.retrieve(forKey: userDefaultsKey) as? Data else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            let learner = try decoder.decode(Learner.self, from: learnerData)
            return learner
        } catch {
            print("Error decoding learner: \(error)")
            return nil
        }
    }
}
