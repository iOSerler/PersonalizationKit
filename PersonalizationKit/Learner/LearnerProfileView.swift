//
//  ProfileView.swift
//  namaz
//
//  Created by Nursultan Askarbekuly on 12.08.2023.
//  Copyright © 2023 Nursultan Askarbekuly. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
public struct LearnerProfileView: View {
    
    @StateObject var localLearner = LocalLearner.shared
    @StateObject var engagementService = EngagementService.shared
    
    private var personalizationQuestions: [QuestionData]
    private var personalizationAction: (() -> Void)?
    @State private var showFullHistory = false
    
    public init(personalizationQuestions: [QuestionData], personalizationAction: (() -> Void)? = nil) {
        self.personalizationQuestions = personalizationQuestions
        self.personalizationAction = personalizationAction
    }
    
    public var body: some View {
        List {
            if let learnerProperties = localLearner.learner?.properties {
                Section(header: Text("learnerProfile".localized())) {
                    
                    ForEach(learnerProperties.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        if let question = personalizationQuestions.first(where: {$0.id == key}),
                           let option = question.optionsData.first(where: {$0.id == value}){
                            VStack(alignment: .leading, spacing: 4) {
                                Text(question.title)
                                    .multilineTextAlignment(.leading)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Text("\(option.text)")
                                    .multilineTextAlignment(.leading)
                            }
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(key.localized())
                                    .multilineTextAlignment(.leading)
                                    .font(.footnote)
                                    .foregroundColor(.gray)
                                Text(value)
                                    .multilineTextAlignment(.leading)
                            }
                        }
                        
                    }
                    
                    Button("updateLearnerInfo".localized()) {
                        personalizationAction?()
                    }
                }
            }
            
            if let engagements = engagementService.localEngagementHistory {
                Section("activitiesHistory".localized()) {
                    
                    let filteredEngagements = Array(engagements.filter({ ["audio", "prayer", "article", "quiz", "test", "navigation"].contains($0.type) }).reversed())
                    
                    ForEach(showFullHistory ? filteredEngagements : Array(filteredEngagements.prefix(5)), id: \.id) { engagement in
                        
                        let value = engagement.value != nil ? engagement.value! : -1
                        
                        switch engagement.type {
                        case "audio":
                            let valueString = value > 0 ? "\(Int(value))x" : "-"
                            HistoryItemView(title: engagement.activityId, image: "play.circle", date: formattedDate(engagement.completionDate ?? Date()), type: "audio".localized(), value: valueString)
                        case "article", "prayer","quiz", "test":
                            let valueString = value > 0 ? "\(Int(value*100))%" : "-"
                            let image = engagement.type == "prayer" ? "cube.fill" : "doc.append"
                            HistoryItemView(title: engagement.activityId, image: image, date: formattedDate(engagement.completionDate ?? Date()), type: engagement.type.localized(), value: valueString)
                        default:
                            HistoryItemView(title: engagement.activityId, image: "platter.filled.top.iphone", date: formattedDate(engagement.completionDate ?? Date()), type: engagement.type.localized(), value: "-")
                        }
                    }
                    
                    if !showFullHistory {
                        Button("showMore".localized()) {
                            showFullHistory = true
                        }
                    }
                    
                }
            }
        }
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "N/A" }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
}

@available(iOS 13.0, *)
struct HistoryItemView: View {
    
    let title: String
    let image: String
    let date: String
    let type: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: image)
                .padding(.bottom, 12)
            VStack(alignment: .leading) {
                Text(title)
                Text(type)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(value)
                    .font(.footnote)
                Text(date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
        }
    }
}
