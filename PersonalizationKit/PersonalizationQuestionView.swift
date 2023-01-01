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
    
    var question: QuestionData {
        questions[questionIndex]
    }
    
    @State private var questionIndex = 0
    @State private var offsetX: CGFloat = 0
    @State private var isAnimationInProgress = false

    public init(
        assets: PersonalizationAssets,
        completePersonalization: (() -> Void)?,
        questions: [QuestionData],
        storage: PersonalizationStorage
    ) {
        self.assets = assets
        self.completePersonalization = completePersonalization
        self.questions = questions
        self.storage = storage
    }
    
    public var body: some View {
        
        VStack(alignment: .center) {
            CustomProgressBarView(assets: assets,
                                  numQuestions: questions.count,
                                  progress: questionIndex+1)
            
            VStack(alignment: .center) {
                
                if !question.image.isEmpty {
                    Image(question.image)
                        .padding(.top, 10)
                } else {
                    Spacer()
                }
                
                Text(question.title)
                    .font(Font.custom(assets.titleFont, size: 21))
                    .foregroundColor(Color(assets.primaryTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.all, 16)
                
                Text(question.description)
                    .font(Font.custom(assets.descriptionFont, size: 15))
                    .foregroundColor(Color(assets.secondaryTextColor))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if question.type == "checkbox" {
                    CheckboxList(question: question, storage: storage, assets: assets)
                } else if question.type == "singleChoice" {
                    RadioButtonList(question: question, storage: storage, assets: assets)
                    
                }
            }.offset(x: offsetX, y: 0)
            
            if !question.image.isEmpty {
                Spacer()
            }
            
            if questions.count > questionIndex+1 {
                
                Button {
                    
                    if isAnimationInProgress {return}
                                        
                    guard ensureAnOptionWasPicked() else {return}
                    
                    isAnimationInProgress = true
                    
                    let duration = 0.5
                    withAnimation(.easeInOut(duration: duration)) {
                        offsetX = -UIScreen.main.bounds.width
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now()+duration, execute: {
                        self.offsetX = UIScreen.main.bounds.width
                        self.questionIndex += 1

                        withAnimation(.easeInOut(duration: duration)) {
                            offsetX = 0
                            isAnimationInProgress = false
                        }
                    })
                } label: {
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
            
        }.interactiveDismissDisabled()
    }
    
    func ensureAnOptionWasPicked() -> Bool {
        
        var didPickAnOption = false
        
        if question.type == "checkbox" {
            question.optionsData.forEach { optionData in
                if storage.isOptionChecked(question, option: optionData) {
                    didPickAnOption = true
                }
            }
        } else if question.type == "singleChoice" && storage.getChosenOption(question) != "" {
            didPickAnOption = true
        }
        
        
        return didPickAnOption
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
