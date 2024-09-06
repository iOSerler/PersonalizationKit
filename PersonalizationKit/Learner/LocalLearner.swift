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
    
    public func getProperty(_ key: String) -> Any? {
        return self.learner?.properties[key]
    }
    
    public func setProperty(_ value: Any, forKey key: String) {
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
            let data = try encodeLearner(learner)
            StorageDelegate.learnerStorage.store(data, forKey: userDefaultsKey)
        } catch {
            print("Error encoding learner: \(error)")
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
            let learner = try decodeLearner(from: learnerData)
            return learner
        } catch {
            print("Error decoding learner: \(error)")
            return nil
        }
    }
    
    // Custom encoding for `Learner`
    private func encodeLearner(_ learner: Learner) throws -> Data {
        let encoder = JSONEncoder()
        
        // Convert `properties` to JSON
        var learnerDict = learner.properties.mapValues { value -> Any in
            if let value = value as? [String: Any] {
                return value
            } else if let value = value as? [Any] {
                return value
            } else {
                return value
            }
        }

        let jsonData = try JSONSerialization.data(withJSONObject: learnerDict, options: [])
        learnerDict["properties"] = jsonData
        
        return try encoder.encode(learner)
    }

    // Custom decoding for `Learner`
    private func decodeLearner(from data: Data) throws -> Learner {
        let decoder = JSONDecoder()
        var learner = try decoder.decode(Learner.self, from: data)

        if let propertiesData = learner.properties["properties"] as? Data {
            if let decodedProperties = try? JSONSerialization.jsonObject(with: propertiesData, options: []) as? [String: Any] {
                learner.properties = decodedProperties
            }
        }

        return learner
    }
}
