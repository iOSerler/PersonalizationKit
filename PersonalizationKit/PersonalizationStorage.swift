//
//  PersonalizationStorage.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation


public protocol PersonalizationStorage {
    
    func addCheckedOption(_ question: QuestionData, option: OptionData)
    
    func removeCheckedOption(_ question: QuestionData, option: OptionData)
    
    func isOptionChecked(_ question: QuestionData, option: OptionData) -> Bool
    
    func getChosenOption(_ question: QuestionData) -> Int
    
    func setChosenOption(_ question: QuestionData, option: OptionData)
    
}
