//
//  LocalLearner.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 09.08.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public class LocalLearner: ObservableObject {
    
    /// set it before using the singleton
    public static var initialStaticStorage: LearnerStorage! = nil {
        didSet {
            shared = LocalLearner(learnerStorage: initialStaticStorage)
        }
    }

    public static var shared = LocalLearner(learnerStorage: initialStaticStorage)
    
    private init(learnerStorage: LearnerStorage) {
        self.learnerStorage = learnerStorage
    }
    
    private var learnerStorage: LearnerStorage!
    
    
    @Published public var learner: Learner?

    private let userDefaultsKey = "current_learner"
    private var lastLearnerUpdateAttempt: Date?
    
    public func kickstartLocalLearner(analyticsId: UUID, learnerPropertyKeys: [String]) {
                
        if let localLearner = retrieveLocalLearner() {
            self.learner = localLearner
            self.learner?.id = analyticsId
        } else if let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.learner = Learner(id: analyticsId)
            learnerStorage.store(appBuildVersion, forKey: "bundleVersionAtInstall")
        } else {
            print(#function, "error creating a learner")
        }
        
        learnerPropertyKeys.forEach { key in
            if let value = learnerStorage.retrieve(forKey: key) as? String {
                self.learner?.properties[key] = value
            }
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
            learnerStorage.store(data, forKey: userDefaultsKey)
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
        guard let learnerData = learnerStorage.retrieve(forKey: userDefaultsKey) as? Data else {
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
