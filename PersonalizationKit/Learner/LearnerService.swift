//
//  BackendAPI.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 06.07.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public class LearnerService {
    
    /// set it before using the singleton
    public static var staticStorage: LearnerStorage! = nil {
        didSet {
            shared = LearnerService(learnerStorage: staticStorage)
        }
    }

    public static var shared = LearnerService(learnerStorage: staticStorage)
    
    private init(learnerStorage: LearnerStorage) {
        self.learnerStorage = learnerStorage
    }
    
    private let learnerStorage: LearnerStorage
    
    var remoteLearner: Learner?

    private lazy var learnerUrl = "\(learnerStorage.serverUrl)/learner/\(learnerStorage.learnerCollectionName)"
    
    public func kickstartRemoteLearner() {
        
        guard let localLearner = LocalLearner.shared.learner else {
            print(#function, "error getting local learner")
            return
        }
        
        Task {
            do {
                self.remoteLearner = try await self.getRemoteLearner("\(localLearner.id)")
            } catch(let getLearnerError) {
                print(#function, "error getting remote learner", getLearnerError.localizedDescription)
                do {
                    self.remoteLearner = try await self.createRemoteLearner()
                } catch(let createLearnerError) {
                    print(#function, "error creating remote learner", createLearnerError.localizedDescription)
                    return
                }
            }
            
            guard let remoteLearner = remoteLearner else {
                print(#function, "failed to assign remote learner")
                return
            }
            
            do {
                if localLearner != remoteLearner {
                    self.remoteLearner = try await updateRemoteLearner()
                }
            } catch(let updateLearnerError) {
                print(#function, "error updating remote learner", updateLearnerError.localizedDescription)
            }
            
        }
    }
        
    public func createRemoteLearner() async throws -> Learner {
        
        guard let learner = LocalLearner.shared.learner else {
            print(#function, "Error learner update failed: local learner is nil")
            throw ServiceError.missingInput
        }
        
//        print(#function, "attempting to create a learner:", learner)
        
        guard let url = URL(string: learnerUrl) else {
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let requestBody = try JSONEncoder().encode(learner)
            request.httpBody = requestBody
        } catch {
            print("Failed to encode learner: \(error)")
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw ServiceError.requestFailed
            }
            guard let learner = try? JSONDecoder().decode(Learner.self, from: data) else {
                throw ServiceError.decodingFailed
            }
            return learner
        } catch {
            // Handle other errors
            print(#function, "error creating remote learner: \(error.localizedDescription)")
            throw error
        }
    }
    
    public func getRemoteLearner(_ id: String) async throws -> Learner {
        /// FIXME can it get the learner from firestore? ≥,fdscaxz
        guard let url = URL(string: "\(learnerUrl)/\(id)") else {
            print(#function, "Failed URL initialization")
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print(#function, "failed response initialization")
                throw ServiceError.failedResponseInitialization
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print(#function, "Request failed with \(httpResponse.statusCode)")
                throw ServiceError.requestFailed
            }
            
            //                print(String(data: data, encoding: .utf8))
            
            guard let remoteLearner = try? JSONDecoder().decode(Learner.self, from: data) else {
                print(#function, "Failed to initilize learner from data:", String(decoding: data, as: UTF8.self))
                throw ServiceError.decodingFailed
            }
            
//            print("remote learner retrieved:", remoteLearner)
            
            return remoteLearner
            
        } catch {
            // Handle other errors
            print(#function, "error getting the remote learner: \(error.localizedDescription)")
            throw error
        }
    }

    public func updateRemoteLearner() async throws -> Learner {
                
        guard let learner = LocalLearner.shared.learner else {
            print(#function, "Error learner update failed: local learner is nil")
            throw ServiceError.missingInput
        }
    
//        print(#function, "learner update initated: \(learner)")
        
        guard let url = URL(string: "\(learnerUrl)") else {
            throw ServiceError.failedURLInitialization
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let requestBody = try encoder.encode(learner)
            request.httpBody = requestBody
        } catch {
            print("Failed to encode learner: \(error)")
            throw ServiceError.encodingFailed
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                print(#function, "failed response initialization")
                throw ServiceError.failedResponseInitialization
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print(#function, "Request failed with \(httpResponse.statusCode)")
                throw ServiceError.requestFailed
            }
            
            guard let updatedLearner = try? JSONDecoder().decode(Learner.self, from: data) else {
                throw ServiceError.decodingFailed
            }
            
//            print(#function, "learner updated successfully: \(updatedLearner)")
            
            return updatedLearner
        } catch {
            // Handle other errors
            print("failed to update remote learner")
            throw error
        }
    }
    
    
}
