//
//  QuestionnaireStorage.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation


public protocol QuestionnaireStorage {
    
    // MARK: -  PERSONALIZATION
    
    func addCheckedOption(_ question: QuestionData, option: OptionData)
    
    func removeCheckedOption(_ question: QuestionData, option: OptionData)
    
    func isOptionChecked(_ question: QuestionData, option: OptionData) -> Bool
    
    func getChosenOption(_ question: QuestionData) -> String
    
    func setChosenOption(_ question: QuestionData, option: OptionData)
    
}



public class LearnerStorage: NSObject {
    
    public static let shared = LearnerStorage()
    
    public func store(_ anyObject: Any, forKey key: String) {
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.set(anyObject, forKey: key)
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.synchronize()
    }
    
    public func retrieve(forKey key: String) -> Any? {
        if let any = UserDefaults(suiteName: "group.com.nurios.namazapp")?.object(forKey: key) {
            return any
        } else if let any = UserDefaults.standard.object(forKey: key) {
            return any
        } else {
            return nil
        }
    }
    
    public func remove(forKey key: String) {
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.removeObject(forKey: key)
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.synchronize()
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    public func getAllItemKeys(withPrefix: String) -> [String] {
        return Array(UserDefaults(suiteName: "group.com.nurios.namazapp")?.dictionaryRepresentation().keys.filter { (key) -> Bool in
                return key.contains(withPrefix)
        } ?? [])
    }
    
}
