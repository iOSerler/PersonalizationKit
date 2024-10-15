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

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        // Clean the properties before encoding
        let cleanProperties = properties.filter { key, value in
            return !(key.isEmpty || value.isEmpty)
        }
        try container.encode(cleanProperties, forKey: .properties)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        // Attempt to decode properties, default to empty dictionary if it fails
        if let decodedProperties = try? container.decode([String: String].self, forKey: .properties) {
            // Clean the properties after decoding
            self.properties = decodedProperties.filter { key, value in
                return !(key.isEmpty || value.isEmpty)
            }
        } else {
            self.properties = [:]
        }
    }
}

extension Learner: Equatable {
    public static func == (lhs: Learner, rhs: Learner) -> Bool {
        return lhs.id == rhs.id && NSDictionary(dictionary: lhs.properties).isEqual(to: rhs.properties)
    }
}
