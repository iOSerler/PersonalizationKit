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
            
            if let learner = localLearner.learner {
                Section(header: Text("learnerProfile".localized())) {
                    if let city = learner.city {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("cityIP".localized())
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text(city)
                                .multilineTextAlignment(.leading)
                        }
                    }
                                        
                    if let question = personalizationQuestions.first(where: {$0.id == "knowledge_level"}),
                       let priorKnowledge = learner.priorKnowledge,
                       let option = question.optionsData.first(where: {$0.id == priorKnowledge}){
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.title)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(option.text)")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    
                    if let question = personalizationQuestions.first(where: {$0.id == "motivation"}),
                       let goal = learner.goal,
                       let option = question.optionsData.first(where: {$0.id == goal}){
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.title)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(option.text)")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    if let question = personalizationQuestions.first(where: {$0.id == "age_range"}),
                       let ageRange = learner.ageRange,
                       let option = question.optionsData.first(where: {$0.id == ageRange}){
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.title)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(option.text)")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    if let question = personalizationQuestions.first(where: {$0.id == "marketing_source"}),
                       let marketingSource = learner.marketingSource,
                       let option = question.optionsData.first(where: {$0.id == marketingSource}){
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(question.title)
                                .multilineTextAlignment(.leading)
                                .font(.footnote)
                                .foregroundColor(.gray)
                            Text("\(option.text)")
                                .multilineTextAlignment(.leading)
                        }
                    }
                    
                    Button("updateLearnerInfo".localized()) {
                        personalizationAction?()
                    }
                    
                    
                    
                    //                    if let properties = learner.properties {
                    //                        ForEach(properties.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                    //                            Text("\(key): \(value)")
                    //                        }
                    //                    }
                }
            }
            
            if let engagements = engagementService.localEngagementHistory {
                Section("activitiesHistory".localized()) {
                    
                    let filteredEngagements = Array(engagements.filter({ ["audio", "prayer", "article", "quiz", "test"].contains($0.type) }).reversed())
                    
                    ForEach(showFullHistory ? filteredEngagements : Array(filteredEngagements.prefix(5)), id: \.id) { engagement in
                        
                        if engagement.type == "audio", let value = engagement.value {
                            
                            let valueString = value > 0 ? "\(Int(value))x" : "-"
                            HistoryItemView(title: engagement.activityId, image: "play.circle", date: formattedDate(engagement.completionDate ?? Date()), type: "audio".localized(), value: valueString)
                            
                        } else if engagement.type == "prayer", let value = engagement.value {
                            
                            let valueString = value > 0 ? "\(Int(value*100))%" : "-"
                            HistoryItemView(title: engagement.activityId, image: "cube.fill", date: formattedDate(engagement.completionDate ?? Date()), type: "fardPrayer".localized(), value: valueString)
                            
                        } else if engagement.type == "article", let value = engagement.value {
                            let valueString = value > 0 ? "\(Int(value*100))%" : "-"
                            HistoryItemView(title: engagement.activityId, image: "doc.append", date: formattedDate(engagement.completionDate ?? Date()), type: "article".localized(), value: valueString)
                            
                        } else if (engagement.type == "quiz" || engagement.type == "test"), let value = engagement.value {
                            let valueString = value > 0 ? "\(Int(value*100))%" : "-"
                            HistoryItemView(title: engagement.activityId, image: "flag", date: formattedDate(engagement.completionDate ?? Date()), type: "quiz".localized(), value: valueString)
                            
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
