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

        // Make a copy of the properties dictionary to prevent concurrent modification
        let propertiesCopy = properties

        var propertiesContainer = container.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: .properties)
        for (key, value) in propertiesCopy {
            guard let codingKey = DynamicCodingKeys(stringValue: key) else {
                print("Warning: Could not create coding key for key: \(key)")
                continue
            }

            // Log the type of each value
            print("Encoding key: \(key), value type: \(type(of: value))")

            switch value {
            case let value as String:
                try propertiesContainer.encode(value, forKey: codingKey)
            case let value as Int:
                try propertiesContainer.encode(value, forKey: codingKey)
            case let value as Double:
                try propertiesContainer.encode(value, forKey: codingKey)
            case let value as Bool:
                try propertiesContainer.encode(value, forKey: codingKey)
            case let value as [String: Any]:
                // Safely serialize nested dictionaries to JSON string
                let nestedData = try JSONSerialization.data(withJSONObject: value, options: [])
                if let nestedString = String(data: nestedData, encoding: .utf8) {
                    try propertiesContainer.encode(nestedString, forKey: codingKey)
                } else {
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode nested dictionary for key \(key)"))
                }
            case let value as [Any]:
                // Safely serialize arrays to JSON string
                let arrayData = try JSONSerialization.data(withJSONObject: value, options: [])
                if let arrayString = String(data: arrayData, encoding: .utf8) {
                    try propertiesContainer.encode(arrayString, forKey: codingKey)
                } else {
                    throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode array for key \(key)"))
                }
            default:
                // Handle unsupported types
                throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unsupported type \(type(of: value)) for key \(key)"))
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
