//
//  Assessment.swift
//  PersonalizationKit
//
//  Created by Nursultan Askarbekuly on 12.10.2024.
//

import Foundation

public struct LetterMastery: Codable {
    public var letter: String
    public var sound: Double
    public var shape: Double
    public var soundExercises: Int
    public var shapeExercises: Int
    
    enum CodingKeys: String, CodingKey {
        case letter, sound, shape
        case soundExercises = "sound_exercises"
        case shapeExercises = "shape_exercises"
    }
}

public struct Assessment: Codable {
    public var letterMastery: [LetterMastery]
    var engagementLevel: Int
    
    public var selectLettersForRevision: [String] {
        // Filter out letters with 0 exercises count
        let filteredLetters = letterMastery.filter { $0.soundExercises > 0 || $0.shapeExercises > 0 }.shuffled()
        
        // Sort by lowest mastery scores (consider both sound and shape)
        let sortedLetters = filteredLetters.sorted { (a, b) -> Bool in
            let aMinScore = min(a.sound, a.shape)
            let bMinScore = min(b.sound, b.shape)
            return aMinScore < bMinScore
        }
        
        // Select up to 4 letters for revision
        return Array(sortedLetters.prefix(4)).map { $0.letter }
    }

    enum CodingKeys: String, CodingKey {
        case letterMastery = "letter_mastery"
        case engagementLevel = "engagement_level"
    }
}
