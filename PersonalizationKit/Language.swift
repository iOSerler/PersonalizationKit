//
//  Language.swift
//  VerseRecorder
//
//  Created by Nursultan Askarbekuly on 01.01.2023.
//

import Foundation

enum Language: Int {
    case english = 0
    case russian = 1
}


var globalLanguage: Language {
    
    /// check if language is already set
    if let langIndex = UserDefaults(suiteName: "group.com.nurios.namazapp")?.object(forKey: "language") as? Int {
        return Language(rawValue: langIndex) ?? .english
    }
    
    /// check if language is already set
    if let langIndex = UserDefaults.standard.object(forKey: "language") as? Int {
        return Language(rawValue: langIndex) ?? .english
    }
    
    /// if not set the app language according to the device language
    let langIndex: Int = Locale.current.languageCode == "ru" ? 1 : 0
    return Language(rawValue: langIndex) ?? .english
    
}

var isRussian: Bool {
    globalLanguage == .russian
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed: CharacterSet = .urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}


extension String {
    func localized() -> String {
        
        if isRussian {
            return getRussian()
        } else {
            return getEnglish()
        }
    }
    
    public func getEnglish() -> String {
        let en = [
            "Continue": "Continue",
            "Done": "Done",
        ]
        
        return en[self] ?? self
    }
    
    public func getRussian() -> String {
        
        let ru = [
            "Continue": "Следующий",
            "Done": "Завершить",
        ]
        
        return ru[self] ?? self
    }
}
