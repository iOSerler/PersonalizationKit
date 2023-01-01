//
//  CheckboxList.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

@available(iOS 15, *)
struct CheckboxList: View {
    
    let question: QuestionData
    let storage: PersonalizationStorage
    let assets: PersonalizationAssets
    
    var body: some View {
        List {
            ForEach(question.optionsData) { optionData in
                
                CheckboxRow(
                    optionData: optionData,
                    tapAction: { checked in
                        if checked {
                            storage.addCheckedOption(question, option: optionData)
                        } else {
                            storage.removeCheckedOption(question, option: optionData)
                        }
                    },
                    assets: assets,
                    checked: storage.isOptionChecked(question, option: optionData)
                )
                .padding()
                .listRowSeparator(.visible, edges: .bottom)
                .listRowSeparator(.hidden, edges: .all)
            }
        }.listStyle(.plain)
    }
}

@available(iOS 15, *)
struct CheckboxRow: View {
    
    let optionData: OptionData
    let tapAction: (Bool) -> Void
    let assets: PersonalizationAssets
    
    @State var checked: Bool
    
    var body: some View {
        HStack {
            self.checked ? Image(systemName: "checkmark.circle.fill").foregroundColor(Color(uiColor:assets.primaryLightColor)) : Image(systemName: "circle").foregroundColor(Color(uiColor:assets.primaryLightColor))
            Text(optionData.emoji)
                .padding(.leading, 10)
            Text(optionData.text)
            Spacer()
        }.contentShape(Rectangle())
            .onTapGesture(perform: {
                checked.toggle()
                tapAction(checked)
                
            })
    }
}
