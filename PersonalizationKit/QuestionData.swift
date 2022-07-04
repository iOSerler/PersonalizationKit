//
//  QuestionData.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

public struct QuestionData: Decodable {
    public var id: Int
    public var type: String
    public var image: String
    public var titleEn: String
    public var titleRu: String
    public var descriptionEn: String
    public var descriptionRu: String
    public var optionsData: [OptionData]
    
    public var title: String {
        titleEn
    }
    
    public var description: String {
        descriptionEn
    }
    
}
