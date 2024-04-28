//
//  PersonalizationStorage.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import Foundation


public protocol PersonalizationStorage {
    
    // MARK: -  PERSONALIZATION
    
    func addCheckedOption(_ question: QuestionData, option: OptionData)
    
    func removeCheckedOption(_ question: QuestionData, option: OptionData)
    
    func isOptionChecked(_ question: QuestionData, option: OptionData) -> Bool
    
    func getChosenOption(_ question: QuestionData) -> String
    
    func setChosenOption(_ question: QuestionData, option: OptionData)
    
}



class Storage: NSObject {
    
    static let shared = Storage()
    
    func store(_ anyObject: Any, forKey key: String) {
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.set(anyObject, forKey: key)
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.synchronize()
    }
    
    func retrieve(forKey key: String) -> Any? {
        if let any = UserDefaults(suiteName: "group.com.nurios.namazapp")?.object(forKey: key) {
            return any
        } else if let any = UserDefaults.standard.object(forKey: key) {
            return any
        } else {
            return nil
        }
    }
    
    func remove(forKey key: String) {
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.removeObject(forKey: key)
        UserDefaults(suiteName: "group.com.nurios.namazapp")?.synchronize()
        
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getAllItemKeys(withPrefix: String) -> [String] {
        return Array(UserDefaults(suiteName: "group.com.nurios.namazapp")?.dictionaryRepresentation().keys.filter { (key) -> Bool in
                return key.contains(withPrefix)
        } ?? [])
    }
    
}
