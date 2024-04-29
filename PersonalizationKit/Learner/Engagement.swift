//
//  Engagement.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 09.08.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import Foundation

@available(iOS 13, *)
public struct Engagement: Codable {
    let id: UUID
    var learnerId: UUID
    public let activityId: String
    public let type: String
    let value: Double?
    let startDateString: String?
    let completionDateString: String?
    
    var startDate: Date? {
        guard let startDateString = startDateString else {
            return nil
        }
        return startDateString.isoStringToDate()
    }
    
    var completionDate: Date? {
        guard let completionDateString = completionDateString else {
            return nil
        }
        return completionDateString.isoStringToDate()
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case learnerId = "learner_id"
        case activityId = "activity_id"
        case type
        case value
        case startDateString = "start_date"
        case completionDateString = "completion_date"
    }
    
    
    init?(activityId: String,
          type: String,
          value: Double?,
          startDate: Date) {
            
        let dateFormatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            return dateFormatter
        }()

        
        guard let learnerId = LocalLearner.shared.learner?.id else {
            print(#function, "error: no learner id")
            return nil
        }
        
        let id = UUID()
        let startDateString = dateFormatter.string(from: startDate)
        let completionDateString = dateFormatter.string(from: Date())
        
        self.id = id
        self.learnerId = learnerId
        self.activityId = activityId
        self.type = type
        self.value = value
        self.startDateString = startDateString
        self.completionDateString = completionDateString
    }

}



extension String {
    
    func isoStringToDate() -> Date? {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            var decimalPointCount = 10
            while decimalPointCount > 0 {
                let format = "yyyy-MM-dd'T'HH:mm:ss." + String(repeating: "S", count: decimalPointCount) + "Z"
                dateFormatter.dateFormat = format
                if let date = dateFormatter.date(from: self) {
                    return date
                }
                decimalPointCount -= 1
            }
            
            return nil // Unable to parse the date string with any format
        }
    }
    
}
