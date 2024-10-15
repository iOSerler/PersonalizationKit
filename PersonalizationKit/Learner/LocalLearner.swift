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

    public static let shared = LocalLearner()

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
    
    public func getProperty(_ key: String) -> Any? {
        return self.learner?.properties[key]
    }
    
    public func setProperty(_ value: String, forKey key: String) {
        guard !key.isEmpty else {
            print("Attempted to set a property with an empty key.")
            return
        }
        guard !value.isEmpty else {
            print("Attempted to set a property with an empty value.")
            return
        }
        self.learner?.properties[key] = value
        saveLocalLearner()
    }
    
    /// save local => update remote
    private func saveLocalLearner() {
        
        guard let learner = self.learner else {
            // The current learner is nil
            return
        }
        
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(learner)
            StorageDelegate.learnerStorage.store(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding learner: \(error)")
            return
        }
        
        guard #available(iOS 15.0, *) else {
            return
        }
        
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

        do {
            var learner = try JSONDecoder().decode(Learner.self, from: learnerData)
            // Clean the properties after decoding
            learner.properties = learner.properties.filter { key, value in
                return !(key.isEmpty || value.isEmpty)
            }
            return learner
        } catch {
            print("Error decoding learner: \(error)")
            return nil
        }
    }
    
}
