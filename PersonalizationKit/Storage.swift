//
//  QuestionnaireStorage.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation

var serverUrl = "https://namazlive.herokuapp.com"

public protocol LearnerStorage {
    
    func store(_ anyObject: Any, forKey key: String)
    
    func retrieve(forKey key: String) -> Any?
    
    func remove(forKey key: String)
    
    func getAllItemKeys(withPrefix: String) -> [String]
    
    func localizedString(forKey key: String) -> String
    
    static var isRussian: Bool { get }
    
}
