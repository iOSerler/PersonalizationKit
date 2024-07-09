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
    
    init(id: UUID, properties: [String: String] = [:]) {
        self.id = id
        self.properties = properties
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        if let props = try container.decodeIfPresent([String: String].self, forKey: .properties) {
            properties = props
        } else {
            // Decode each old property and store it in the properties dictionary
            let allKeys = container.allKeys
            var props = [String: String]()

            for key in allKeys {
                if key.stringValue != "id" {
                    let value = try container.decodeIfPresent(String.self, forKey: key)
                    props[key.stringValue] = value ?? ""
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
