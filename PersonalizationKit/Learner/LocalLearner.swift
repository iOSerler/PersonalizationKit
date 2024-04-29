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

    public var isAnAbsoluteChad: Bool {
        guard  let learner = learner else {
            print(#function, "learner is not initialized yet")
            return false
        }
        
        guard let _ = learner.goal else {
            print(#function, "learner doesn't have a goal")
            return false
        }
        
        guard let localHistory = EngagementService.shared.localEngagementHistory else {
            print(#function, "history is not initialized yet")
            return false
        }
        
        let containsFirstLaunch = localHistory.contains(where: {$0.activityId == "launch" && $0.value == 1 })
        let hasLongEnoughHistory = localHistory.count > 100
        
        return containsFirstLaunch && hasLongEnoughHistory
    }
    
    public func kickstartLocalLearner(analyticsId: UUID) {
                
        if let localLearner = retrieveLocalLearner() {
            self.learner = localLearner
        } else if let appBuildVersion = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            self.learner = Learner(id: analyticsId, gender: nil, language: nil, countryCode: nil, city: nil, priorKnowledge: nil, goal: nil, properties: nil, bundleVersionAtInstall: appBuildVersion)
        } else {
            print(#function, "error creating a learner")
        }
        
    }
    
    public func setFCMToken(_ fcmToken: String) {
        if let storedToken = self.learner?.fcmToken,
           storedToken == fcmToken {
            // do nothing
        } else {
            self.learner?.fcmToken = fcmToken
            updateLocalLearner()
        }
    }
    
    public func setProperty(_ value: String, forKey key: String) {
        self.learner?.properties?[key] = value
        updateLocalLearner()
    }
    
    /// update local => save local => update remote
    
    func updateLocalLearner() {
        
        guard var learner = self.learner else {
            print("the current learner or local user is nil")
            return
        }
        
        if let analyticsIdString = learnerStorage.retrieve(forKey: LearnerProperties.analyticsId.rawValue) as? String,
           let analyticsId = UUID(uuidString: analyticsIdString) {
            learner.id = analyticsId
        }
        learner.gender = learnerStorage.retrieve(forKey: LearnerProperties.gender.rawValue) as? Int ?? 0
        learner.language = learnerStorage.retrieve(forKey: LearnerProperties.language.rawValue) as? Int ?? 0
        learner.countryCode = learnerStorage.retrieve(forKey: LearnerProperties.countryCode.rawValue) as? String
        learner.city = learnerStorage.retrieve(forKey: LearnerProperties.city.rawValue) as? String
        learner.ageRange = learnerStorage.retrieve(forKey: LearnerProperties.ageRange.rawValue) as? String
        learner.marketingSource =  learnerStorage.retrieve(forKey: LearnerProperties.marketingSource.rawValue) as? String
        learner.priorKnowledge = learnerStorage.retrieve(forKey: LearnerProperties.knowledgeLevel.rawValue) as? String
        learner.goal = learnerStorage.retrieve(forKey: LearnerProperties.motivation.rawValue) as? String
        
        DispatchQueue.main.async {
            self.learner = learner
            self.saveLocalLearner()
        }
    }
    
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
