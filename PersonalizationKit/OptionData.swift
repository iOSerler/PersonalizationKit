//
//  OptionData.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

public struct OptionData: Identifiable, Equatable {
    public let id: Int
    public let firstPart: String
    public let secondPart: String
    
    public init(
        id: Int,
        firstPart: String,
        secondPart: String
    ) {
        self.id = id
        self.firstPart = firstPart
        self.secondPart = secondPart
    }
}
