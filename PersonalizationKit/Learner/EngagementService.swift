//
//  EngagementService.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 09.08.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

enum ServiceError: Error {
    case missingInput
    case missingToken
    case failedURLInitialization
    case encodingFailed
    case failedResponseInitialization
    case requestFailed
    case decodingFailed
}

@available(iOS 13.0, *)
public class EngagementService: ObservableObject {
    
    /// set it before using the singleton
    public static var initialStaticStorage: LearnerStorage! = nil {
        didSet {
            shared = EngagementService(learnerStorage: initialStaticStorage)
        }
    }

    public static var shared = EngagementService(learnerStorage: initialStaticStorage)
    
    private init(learnerStorage: LearnerStorage) {
        self.learnerStorage = learnerStorage
    }
    
    private let learnerStorage: LearnerStorage
    
    public var localEngagementHistory: [Engagement]? {
        didSet {
            saveLocalEngagementHistory()
        }
    }

    private let engagementUrl = "https://namazlive.herokuapp.com/engagements"
    private let userDefaultsKey = "engagement_history"
    
    public func kickstartEngagementHistory() {
        
        guard let localEngagementHistory = retrieveEngagementHistory() else {
            print(#function, "error getting local engagement history")
            self.localEngagementHistory = []
            return
        }
        
        self.localEngagementHistory = localEngagementHistory
        print("localEngagementHistory:", localEngagementHistory.count)
        
    }
    
    public func syncActivitiesToFS() {
        Task {
            do {
                let remotelyAddedEngagements = try await addAllNewEngagementsToRemoteHistory()
                    print("successfully added remote engagements:", remotelyAddedEngagements)
            } catch {
                print(#function, "error adding remote engagements: \(error.localizedDescription )")
            }
        }
    }
    
    public func addEngagementToHistory(_ engagement: Engagement) {
        /// add to local history
        if let _ = localEngagementHistory,
           !localEngagementHistory!.contains(where: {$0.id == engagement.id}) {
            localEngagementHistory?.append(engagement)
        }

//        /// if it's a premium user, add to remote history
//        guard let learnerType = LocalLearner.shared.getProperty(LearnerProperties.learnerType.rawValue),
//              learnerType == "premium" else {
//            return
//        }
//        
//        Task {
//            do {
//                let engagement = try await addEngagementToRemoteHistory(engagement)
//                learnerStorage.store(true, forKey: "\(engagement.id)")
//            } catch {
//                print(#function, "error: \(error.localizedDescription)")
//            }
//        }
//        
//    }
//        
//    public func addEngagementToRemoteHistory(_ engagement: Engagement) async throws -> Engagement {
//        
//        /// add to remote history
//        guard let url = URL(string: engagementUrl) else {
//            throw ServiceError.failedURLInitialization
//        }
//        
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        do {
//            let requestBody = try JSONEncoder().encode(engagement)
//            request.httpBody = requestBody
//        } catch {
//            print("Failed to encode engagement: \(error.localizedDescription)")
//        }
//        
//        do {
//            let (data, response) = try await URLSession.shared.data(for: request)
//            guard let httpResponse = response as? HTTPURLResponse,
//                  (200...299).contains(httpResponse.statusCode) else {
//                print(#function, "Failed with response: \( (response as? HTTPURLResponse)?.statusCode ?? 0 )", String(data: data, encoding: .utf8) ?? "")
//                throw ServiceError.requestFailed
//            }
//            guard let engagement = try? JSONDecoder().decode(Engagement.self, from: data) else {
//                print(#function, "Failed to decode", String(data: data, encoding: .utf8) ?? "")
//                throw ServiceError.decodingFailed
//            }
//            
////            print(#function, "engagement added to remote history:", engagement)
//            return engagement
//        } catch {
//            print(#function, "Failed with error: \(error.localizedDescription)")
//            throw error
//        }
    }
    
    public func addAllNewEngagementsToRemoteHistory() async throws -> [Engagement] {
        
        var engagementsForUpload: [Engagement] = []
        
        for localEngagement in localEngagementHistory ?? [] {
            
            if learnerStorage.retrieve(forKey: "\(localEngagement.id)") as? Bool ?? false {
//                print("skipping")
                continue
            }
            
            engagementsForUpload.append(localEngagement)
            
            if engagementsForUpload.count > 500 {
                break
            }
        }
        
        
        if engagementsForUpload.count < 200 {
            print("too few new engagements, no need to upload yet.")
            return []
        }
        
        /// add to remote history
        guard let url = URL(string: engagementUrl+"/bulk") else {
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try JSONEncoder().encode(engagementsForUpload)
            request.httpBody = requestBody
        } catch {
            print("Failed to encode engagement: \(error)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(#function, "Failed with response: \( (response as? HTTPURLResponse)?.statusCode ?? 0 )", String(data: data, encoding: .utf8) ?? "")
                throw ServiceError.requestFailed
            }
            guard let engagements = try? JSONDecoder().decode([Engagement].self, from: data) else {
                print(#function, "Failed to decode", String(data: data, encoding: .utf8) ?? "")
                throw ServiceError.decodingFailed
            }
            
            for engagement in engagements {
                learnerStorage.store(true, forKey: "\(engagement.id)")
            }
            
            print(#function, "engagements added to remote history:", engagements)
            return engagements
        } catch {
            // Handle other errors
            print(#function, "error: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    private func saveLocalEngagementHistory() {
        
        guard let localEngagementHistory = self.localEngagementHistory else {
            print(#function, "Error localEngagementHistory is nil")
            return
        }
        
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(localEngagementHistory)
            learnerStorage.store(data, forKey: userDefaultsKey)
        } catch {
            print(#function, "Error encoding localEngagementHistory: \(error)")
        }
    }
    
    private func retrieveEngagementHistory() -> [Engagement]? {
        guard let engagementHistoryData = learnerStorage.retrieve(forKey: userDefaultsKey) as? Data else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode([Engagement].self, from: engagementHistoryData)
        } catch {
            print(#function, "Error decoding engagement history: \(error)")
            return nil
        }
    }
    
    public func getEngagement(activityId: String, type: String) -> Engagement? {
        if let localEngagementHistory = localEngagementHistory,
           let engagement = localEngagementHistory.first(where: {$0.activityId == activityId && $0.type == type}) {
            return engagement
        }
        
        return nil
    }
    
}
