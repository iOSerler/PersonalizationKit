//
//  PersonalizationKit.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//


import SwiftUI

@available(iOS 15, *)
public struct PersonalizationQuestionView: View {
    let learnerStorage: LearnerStorage
    let assets: PersonalizationAssets
    var completePersonalization: (() -> Void)?
    let questions: [QuestionData]
    let startDate: Date
    
    var question: QuestionData {
        questions[questionIndex]
    }
    
    @State private var questionIndex = 0
    @State private var offsetX: CGFloat = 0
    @State private var isAnimationInProgress = false

    public init(
        learnerStorage: LearnerStorage,
        assets: PersonalizationAssets,
        completePersonalization: (() -> Void)?,
        questions: [QuestionData],
        startDate: Date
    ) {
        self.learnerStorage = learnerStorage
        self.assets = assets
        self.completePersonalization = completePersonalization
        self.questions = questions
        self.startDate = startDate
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
                    List {
                        ForEach(question.optionsData) { optionData in
                            
                            CheckboxRow(
                                optionData: optionData,
                                tapAction: { checked in
                                    if checked {
                                        addCheckedOption(question, option: optionData)
                                    } else {
                                        removeCheckedOption(question, option: optionData)
                                    }
                                },
                                assets: assets,
                                checked: isOptionChecked(question, option: optionData)
                            )
                            .padding()
                            .listRowSeparator(.visible, edges: .bottom)
                            .listRowSeparator(.hidden, edges: .all)
                        }
                    }.listStyle(.plain)
                    
                    
                } else if question.type == "singleChoice" {
                    RadioButtonList(question: question, assets: assets, lastChosenOptionId: getChosenOption(question), setChosenOption: setChosenOption(_:option:))
                    
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
                            for question in questions {
                                if question.type == "singleChoice" {
                                    
                                    let userProperty = question.id
                                    let propertyValue = getChosenOption(question)
                                    
                                    //                            print(userProperty, ":", propertyValue)
                                    learnerStorage.store(propertyValue, forKey: "personalization_\(userProperty)")
                                    Analytics.shared.setUserProperty(userProperty, value: propertyValue)
                                }
                            }
                            
                            Analytics.shared.logActivity("personalization", type: "action", value: 1, startDate: startDate)
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
                if isOptionChecked(question, option: optionData) {
                    didPickAnOption = true
                }
            }
        } else if question.type == "singleChoice" && getChosenOption(question) != "" {
            didPickAnOption = true
        } else if question.type == "image" {
            didPickAnOption = true
        }
        
        
        return didPickAnOption
    }
    
    
    func addCheckedOption(_ question: QuestionData, option: OptionData) {
        
        let storageID = "checkBoxQuestionID_\(question.id)"
        if var checkedOptions = learnerStorage.retrieve(forKey: storageID) as? [String] {
            checkedOptions.append(option.id)
            checkedOptions = Array(Set(checkedOptions))
            learnerStorage.store(checkedOptions, forKey: storageID)
        } else {
            learnerStorage.store([option.id], forKey: storageID)
        }
        
                
    }

    func removeCheckedOption(_ question: QuestionData, option: OptionData) {
        let storageID = "checkBoxQuestionID_\(question.id)"
        if var checkedOptions = learnerStorage.retrieve(forKey: storageID) as? [String] {
            var set = Set(checkedOptions)
            set.remove(option.id)
            checkedOptions = Array(set)
            learnerStorage.store(checkedOptions, forKey: storageID)
            
        }
    }
    
    func isOptionChecked(_ question: QuestionData, option: OptionData) -> Bool {
        let storageID = "checkBoxQuestionID_\(question.id)"
        if let checkedOptions = learnerStorage.retrieve(forKey: storageID) as? [String] {
            let set = Set(checkedOptions)
            return set.contains(option.id)
        }
        return false
    }
    
    func getChosenOption(_ question: QuestionData) -> String {
        let storageID = "checkBoxQuestionID_\(question.id)"
        let chosenOption = learnerStorage.retrieve(forKey: storageID) as? String
        return chosenOption ?? ""
    }
    
    func setChosenOption(_ question: QuestionData, option: OptionData) {
        let storageID = "checkBoxQuestionID_\(question.id)"
        learnerStorage.store(option.id, forKey: storageID)
        
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
