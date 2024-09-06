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
    public var properties: [String: Any]

    enum CodingKeys: String, CodingKey {
        case id
        case properties
    }

    init(id: UUID, properties: [String: Any] = [:]) {
        self.id = id
        self.properties = properties
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)

        let propertiesContainer = try container.decode([String: AnyDecodable].self, forKey: .properties)
        var props = [String: Any]()
        
        for (key, value) in propertiesContainer {
            props[key] = value.value
        }
        
        self.properties = props
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)

        // Dynamic key encoding for properties
        var propertiesContainer = container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .properties)
        for (key, value) in properties {
            if let codingKey = DynamicCodingKeys(stringValue: key) {
                if let value = value as? String {
                    try propertiesContainer.encode(value, forKey: codingKey)
                } else if let value = value as? Int {
                    try propertiesContainer.encode(value, forKey: codingKey)
                } else if let value = value as? Double {
                    try propertiesContainer.encode(value, forKey: codingKey)
                } else if let value = value as? Bool {
                    try propertiesContainer.encode(value, forKey: codingKey)
                } else if let value = value as? [String: Any] {
                    // Safely serialize nested dictionaries to JSON
                    if let nestedData = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let nestedString = String(data: nestedData, encoding: .utf8) {
                        try propertiesContainer.encode(nestedString, forKey: codingKey)
                    }
                } else if let value = value as? [Any] {
                    // Safely serialize arrays to JSON
                    if let arrayData = try? JSONSerialization.data(withJSONObject: value, options: []),
                       let arrayString = String(data: arrayData, encoding: .utf8) {
                        try propertiesContainer.encode(arrayString, forKey: codingKey)
                    }
                }
            }
        }
    }
}

// Helper struct to handle dynamic keys safely
struct DynamicCodingKeys: CodingKey {
    var stringValue: String
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    var intValue: Int?
    init?(intValue: Int) {
        return nil
    }
}

// Helper struct to decode mixed types without force unwrapping
struct AnyDecodable: Decodable {
    let value: Any

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let dictValue = try? container.decode([String: AnyDecodable].self) {
            value = dictValue.mapValues { $0.value }
        } else if let arrayValue = try? container.decode([AnyDecodable].self) {
            value = arrayValue.map { $0.value }
        } else {
            value = ""
        }
    }
}

extension Learner: Equatable {
    public static func == (lhs: Learner, rhs: Learner) -> Bool {
        return lhs.id == rhs.id && NSDictionary(dictionary: lhs.properties).isEqual(to: rhs.properties)
    }
}
