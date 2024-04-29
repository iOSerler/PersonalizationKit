//
//  Learner.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 06.07.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

public enum LearnerProperties: String {
    case analyticsId = "analytics_id"
    case gender
    case language
    case countryCode
    case city
    case ageRange = "personalization_age_range"
    case marketingSource = "personalization_marketing_source"
    case knowledgeLevel = "personalization_knowledge_level"
    case motivation = "personalization_motivation"
    case appOpenCount = "app_open_count"
    case experimentParticipant = "experiment_participant"
}

public struct Learner: Codable {
    var id: UUID
    var gender: Int?
    var language: Int?
    var countryCode: String?
    var city: String?
    var priorKnowledge: String?
    var goal: String?
    var ageRange: String?
    var marketingSource: String?
    public var fcmToken: String?
    var properties: [String: String]?
    public var bundleVersionAtInstall: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case gender
        case language
        case countryCode = "country"
        case city
        case priorKnowledge = "prior_knowledge"
        case goal
        case ageRange = "age_range"
        case marketingSource = "marketing_source"
        case fcmToken = "fcm_token"
        case properties
        case bundleVersionAtInstall
    }
}


extension Learner: Equatable {
    public static func == (lhs: Learner, rhs: Learner) -> Bool {
        return lhs.id == rhs.id &&
               lhs.gender == rhs.gender &&
               lhs.language == rhs.language &&
               lhs.countryCode == rhs.countryCode &&
               lhs.city == rhs.city &&
               lhs.priorKnowledge == rhs.priorKnowledge &&
               lhs.goal == rhs.goal &&
               lhs.ageRange == rhs.ageRange &&
               lhs.marketingSource == rhs.marketingSource &&
               lhs.properties == rhs.properties
    }
}
