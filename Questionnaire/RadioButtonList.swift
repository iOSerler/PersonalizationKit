//
//  RadioButtonList.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

@available(iOS 15, *)
struct RadioButtonList: View {
    
    let question: QuestionData
    let storage: QuestionnaireStorage
    let assets: PersonalizationAssets

    @State var lastChosenOptionId = ""
    
    var body: some View {
        ScrollView {
            ForEach(question.optionsData) { optionData in
                
                Button(
                    action: {
                        storage.setChosenOption(question, option: optionData)
                        self.lastChosenOptionId = optionData.id
//                        print(lastChosenOptionId)
                    }, label: {
                        HStack {
                            Text(optionData.emoji)
                                .font(.custom(assets.titleFont, size: 16))
                                .padding(.leading, 20)
                            Text(optionData.text)
                                .font(.custom(assets.titleFont, size: 16))
                                .foregroundColor(Color(assets.primaryTextColor))
                                .multilineTextAlignment(.leading)
                        }
                        .frame(width: UIScreen.main.bounds.width - 60, height: 66, alignment: .leading)
                        .overlay(RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(assets.borderColor), lineWidth: 2))
                        .background(self.lastChosenOptionId == optionData.id ? Color(assets.primaryColor.withAlphaComponent(0.3)) : Color.clear)
                    }
                )
                .cornerRadius(12)
                .padding(.top, 10)
                .onAppear {
                    self.lastChosenOptionId = storage.getChosenOption(question)
//                    print(lastChosenOptionId)
                }
                
            }
            .padding(0)
        }
    }
}
