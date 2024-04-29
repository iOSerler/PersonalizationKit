//
//  QuestionnaireStorage.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

public protocol LearnerStorage {
    
    func store(_ anyObject: Any, forKey key: String)
    
    func retrieve(forKey key: String) -> Any?
    
    func remove(forKey key: String)
    
    func getAllItemKeys(withPrefix: String) -> [String]
    
}
