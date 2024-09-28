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
}

extension Learner: Equatable {
    public static func == (lhs: Learner, rhs: Learner) -> Bool {
        return lhs.id == rhs.id && NSDictionary(dictionary: lhs.properties).isEqual(to: rhs.properties)
    }
}
