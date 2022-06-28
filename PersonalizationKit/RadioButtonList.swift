//
//  RadioButtonList.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

struct RadioButtonList: View {
    
    let question: QuestionData
    let storage: PersonalizationStorage
    let assets: PersonalizationAssets

    @State var chosenOptionId = 0
    
    var body: some View {
        ScrollView {
            ForEach(question.optionsData) { optionData in
                
                RadioButtonRow(
                    assets: assets,
                    optionData: optionData,
                    tapAction: {
                        self.chosenOptionId = optionData.id
                        storage.setChosenOption(question, option: optionData)
                    },
                    chosen: self.chosenOptionId == optionData.id
                )
            }
            .padding(0)
        }.onAppear {
            self.chosenOptionId = storage.getChosenOption(question)
        }
    }
}

struct RadioButtonRow: View {
    var assets: PersonalizationAssets
    let optionData: OptionData
    let tapAction: () -> Void
    let chosen: Bool
    
    var body: some View {
        Button(
            action: {
                tapAction()
            }, label: {
                HStack {
                    Text(optionData.firstPart)
                        .font(.custom(assets.titleFont, size: 16))
                        .foregroundColor(chosen ? Color(assets.primaryColor) : .black)
                        .padding(.leading, 20)
                    Spacer()
                    Text(optionData.secondPart)
                        .font(.custom(assets.descriptionFont, size: 14))
                        .foregroundColor(
                            chosen ?
                            Color(assets.mainTextColor) : Color(assets.descriptionTextColor)
                        )
                        .padding(.trailing, 20)
                }
                .frame(width: UIScreen.main.bounds.width - 60, height: 66, alignment: .leading)
                .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(chosen ? Color(assets.primaryColor) : Color(assets.borderColor), lineWidth: 2))
                .background(chosen ? Color(assets.primaryLighterColor) : .white)
            }
        )
        .cornerRadius(12)
        .padding(.top, 10)
    }
}
