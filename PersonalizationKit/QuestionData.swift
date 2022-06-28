//
//  QuestionData.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

public struct QuestionData {
    public var id: Int
    public var type: String
    public var image: String
    public var title: String
    public var description: String
    public var optionsData: [OptionData]
    
    public init(
        id: Int,
        type: String,
        image: String,
        title: String,
        description: String,
        optionsData: [OptionData]
    ) {
        self.id = id
        self.type = type
        self.image = image
        self.title = title
        self.description = description
        self.optionsData = optionsData
    }
    
}
