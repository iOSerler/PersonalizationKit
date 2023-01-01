//
//  PersonalizationKit.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//


import SwiftUI

@available(iOS 15, *)
public struct PersonalizationQuestionView: View {
    let assets: PersonalizationAssets
    var completePersonalization: (() -> Void)?
    let questions: [QuestionData]
    let storage: PersonalizationStorage
    let question: QuestionData
    
    public init(
        assets: PersonalizationAssets,
        completePersonalization: (() -> Void)?,
        questions: [QuestionData],
        storage: PersonalizationStorage,
        question: QuestionData
    ) {
        self.assets = assets
        self.completePersonalization = completePersonalization
        self.questions = questions
        self.storage = storage
        self.question = question
    }
    
    public var body: some View {
        
        VStack(alignment: .center) {
            CustomProgressBarView(assets: assets,
                                  numQuestions: questions.count,
                                  progress: question.id)
            
            
            if !question.image.isEmpty {
                Image(question.image)
                    .padding(.top, 10)
            } else {
                Spacer()
            }
            
            Text(question.title)
                .font(Font.custom(assets.titleFont, size: 21))
                .foregroundColor(Color(assets.mainTextColor))
                .multilineTextAlignment(.center)
                .padding(.all, 16)
            
            Text(question.description)
                .font(Font.custom(assets.descriptionFont, size: 15))
                .foregroundColor(Color(assets.descriptionTextColor))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if question.type == "checkbox" {
                CheckboxList( question: question, storage: storage, assets: assets)
            } else if question.type == "singleChoice" {
                RadioButtonList(question: question, storage: storage, assets: assets)
            }
            
            if !question.image.isEmpty {
                Spacer()
            }
            
            if questions.count > question.id {
                
                NavigationLink(
                    destination:
                        PersonalizationQuestionView(
                            assets: assets,
                            completePersonalization: completePersonalization,
                            questions: questions,
                            storage: storage,
                            question: questions[question.id]
                        )
                ) {
                    ButtonText(title: "Continue".localized(), assets: assets)
                }
                
            } else {
                Button(action: {
                    DispatchQueue.main.async {
                        withAnimation {
                            completePersonalization?()
                        }
                    }
                }, label: {
                    ButtonText(title: "Done".localized(), assets: assets)
                })
            }
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarHidden(false).transition(.opacity)
    }
}

@available(iOS 15, *)
struct ButtonText: View {
    
    let title: String
    var assets: PersonalizationAssets
    
    var body: some View {
        Text(title)
            .font(Font.custom(assets.titleFont, size: 16))
            .frame(width: UIScreen.main.bounds.width - 60, height: 50, alignment: .center)
            .foregroundColor(Color(assets.buttonTextColor))
            .background(Color(assets.primaryColor))
            .cornerRadius(UIScreen.main.bounds.width/35)
            .padding(.bottom, UIScreen.main.bounds.height/30)
    }
    
    
}
