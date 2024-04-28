//
//  OptionData.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

public struct OptionData: Identifiable, Equatable, Decodable {
    public let id: String
    public let emoji: String
    public let textRu: String
    public let textEn: String

    public var text: String {
        isRussian ? textRu : textEn
    }   
}
