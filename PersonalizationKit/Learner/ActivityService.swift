//
//  ActivityService.swift
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


extension ServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .missingInput:
            return NSLocalizedString("Input data is missing or invalid.", comment: "Missing Input")
        case .missingToken:
            return NSLocalizedString("The required token is missing.", comment: "Missing Token")
        case .failedURLInitialization:
            return NSLocalizedString("Failed to initialize the URL.", comment: "Failed URL Initialization")
        case .encodingFailed:
            return NSLocalizedString("Failed to encode the data.", comment: "Encoding Failed")
        case .failedResponseInitialization:
            return NSLocalizedString("Failed to initialize the response.", comment: "Failed Response Initialization")
        case .requestFailed:
            return NSLocalizedString("The network request failed.", comment: "Request Failed")
        case .decodingFailed:
            return NSLocalizedString("Failed to decode the response data.", comment: "Decoding Failed")
        }
    }
}

@available(iOS 10.0, *)
public class ActivityService {

    public static var shared = ActivityService()
    
    public var localActivityHistory: [ActivityLog]? {
        didSet {
            saveLocalHistory()
        }
    }

    private lazy var analyticsUrl = "\(StorageDelegate.learnerStorage.serverUrl)/analytics/\(StorageDelegate.learnerStorage.activtyLogCollectionName)"
    private let userDefaultsKey = "engagement_history"
    
    public func kickstartActivityService() {
        
        guard let localHistory = retrieveLocalHistory() else {
            print(#function, "error getting local history")
            self.localActivityHistory = []
            return
        }
        
        self.localActivityHistory = localHistory
        print("localActivityHistory:", localHistory.count)
        
    }
    
    @available(iOS 13.0, *)
    public func syncActivitiesToFS() {
        Task {
            do {
                let remotelyAddedActivityLogs = try await logActivitiesToRemoteHistory(minActivitiesToLogCount: 1)
//                print("successfully logged activities to remote storage:", remotelyAddedActivityLogs.map{ "\($0.activityId) \($0.value ?? "")"})
            } catch {
                print(#function, "error logging activities to remote storage") // \( error.localizedDescription)")
            }
        }
    }
    
    public func logActivityToHistory(_ activityLog: ActivityLog) {
        /// add to local history
        if let localHistory = localActivityHistory,
           !localHistory.contains(where: {$0.id == activityLog.id}) {
            self.localActivityHistory?.append(activityLog)
            
            if #available(iOS 13.0, *) {
                Task {
                    do {
                        try await self.logSingleActivitiesToRemoteHistory(activityLog)
                        StorageDelegate.learnerStorage.store(true, forKey: "\(activityLog.id)")
                    } catch {
                        print("failed to log a single activity: ", error.localizedDescription)
                    }
                }
            }
            
        } else {
            print("Error adding history log: either the history is nil or item has been previously added. Local history:", localActivityHistory ?? "nil")
        }
    }
    
    @available(iOS 13.0.0, *)
    public func logActivitiesToRemoteHistory(minActivitiesToLogCount: Int = 100) async throws -> [ActivityLog] {
        
        var activitiesToBeLogged: [ActivityLog] = []
        
        for localLog in localActivityHistory?.sorted(by: {$0.startDate ?? Date() < $1.startDate ?? Date()}) ?? [] {
            
            if StorageDelegate.learnerStorage.retrieve(forKey: "\(localLog.id)") as? Bool ?? false {
                /// skipping item as it was already marked as reported
                continue
            }
            
            activitiesToBeLogged.append(localLog)
            
            if activitiesToBeLogged.count > 500 {
                /// we report up to 500 logs at a time
                break
            }
        }
        
        
        if activitiesToBeLogged.count < minActivitiesToLogCount {
            print("too few new logs, no need to upload yet.")
            throw ServiceError.missingInput
        }
        
        /// add to remote history
        guard let url = URL(string: analyticsUrl+"/bulk") else {
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try JSONEncoder().encode(activitiesToBeLogged)
            request.httpBody = requestBody
        } catch {
            print("Failed to encode the activityLog: \(error)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print(#function, "Failed with response: \( (response as? HTTPURLResponse)?.statusCode ?? 0 )") //, String(data: data, encoding: .utf8) ?? "")
                throw ServiceError.requestFailed
            }
            guard let activityLogs = try? JSONDecoder().decode([ActivityLog].self, from: data) else {
                print(#function, "Failed to decode", String(data: data, encoding: .utf8) ?? "")
                throw ServiceError.decodingFailed
            }
            
            for log in activityLogs {
                StorageDelegate.learnerStorage.store(true, forKey: "\(log.id)")
            }
            
            print(#function, "activities logged to remote history") //:", activityLogs)
            return activityLogs
        } catch {
            // Handle other errors
            throw error
        }
        
    }
    
    @available(iOS 13.0.0, *)
    @discardableResult
    public func logSingleActivitiesToRemoteHistory(_ localActivity: ActivityLog) async throws -> ActivityLog {
            
        /// add to remote history
        guard let url = URL(string: analyticsUrl) else {
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(localActivity)
            request.httpBody = jsonData
        } catch {
            throw ServiceError.encodingFailed
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw ServiceError.requestFailed
        }
        
        do {
            let decoder = JSONDecoder()
            let remoteActivity = try decoder.decode(ActivityLog.self, from: data)
            return remoteActivity
        } catch {
            throw ServiceError.decodingFailed
        }
    }

    
    private func saveLocalHistory() {
        
        guard let localActivitiesHistory = self.localActivityHistory else {
            print(#function, "Error localActivitiesHistory is nil")
            return
        }
        
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(localActivitiesHistory)
            StorageDelegate.learnerStorage.store(data, forKey: userDefaultsKey)
        } catch {
            print(#function, "Error encoding localActivitiesHistory: \(error)")
        }
    }
    
    private func retrieveLocalHistory() -> [ActivityLog]? {
        guard let localHistoryData = StorageDelegate.learnerStorage.retrieve(forKey: userDefaultsKey) as? Data else {
            return nil
        }

        let decoder = JSONDecoder()

        do {
            return try decoder.decode([ActivityLog].self, from: localHistoryData)
        } catch {
            print(#function, "Error decoding local history: \(error)")
            return nil
        }
    }
    
    public func getActivity(activityId: String, type: String?, value: String?) -> ActivityLog? {
        if let localActivityHistory = localActivityHistory,
           let activityLog = localActivityHistory.first(where: {$0.activityId == activityId && (type==nil ? true : $0.type == type!) && (value==nil ? true : $0.value == value!)}) {
            return activityLog
        }
        
        return nil
    }
    
}
