//
//  CheckboxList.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

@available(iOS 15, *)
struct CheckboxRow: View {
    
    let optionData: OptionData
    let tapAction: (Bool) -> Void
    let assets: PersonalizationAssets
    
    @State var checked: Bool
    
    var body: some View {
        HStack {
            Image(systemName: self.checked ? "checkmark.circle.fill" : "circle").foregroundColor(Color(uiColor:assets.primaryColor.withAlphaComponent(0.5)))
            Text(optionData.emoji)
                .padding(.leading, 10)
            Text(optionData.text)
                .multilineTextAlignment(.leading)
            Spacer()
        }.contentShape(Rectangle())
            .onTapGesture(perform: {
                checked.toggle()
                tapAction(checked)
                
            })
    }
}
