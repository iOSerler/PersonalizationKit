//
//  Learner.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 06.07.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

public struct Learner: Codable {
    public var id: UUID
    public var properties: [String: String]

    enum CodingKeys: String, CodingKey {
        case id
        case properties
    }
    
    enum OldCodingKeys: String, CodingKey {
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
    
    init(id: UUID, properties: [String: String] = [:]) {
        self.id = id
        self.properties = properties
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: OldCodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        if let props = try container.decodeIfPresent([String: String].self, forKey: .properties) {
            properties = props
        } else {
            // Decode each old property and store it in the properties dictionary
            let allKeys = container.allKeys
            print("all keys:", allKeys)
            var props = [String: String]()

            for key in allKeys {
                if ["country", "city", "prior_knowledge", "goal", "age_range", "marketing_source", "fcm_token", "bundleVersionAtInstall"].contains(key.stringValue),
                   let value = try? container.decodeIfPresent(String.self, forKey: key) {
                    props[key.stringValue] = value
                }
            }
            
            properties = props
        }
    }
}

extension Learner: Equatable {
    public static func == (lhs: Learner, rhs: Learner) -> Bool {
        return lhs.id == rhs.id && lhs.properties == rhs.properties
    }
}
