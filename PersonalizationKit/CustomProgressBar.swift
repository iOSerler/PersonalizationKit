//
//  CustomProgressBar.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

struct CustomProgressBarView: View {
    var assets: PersonalizationAssets
    var numQuestions: Int
    @Binding var progress: Int
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(1..<numQuestions, id: \.self) { ind in
                HStack {
                    ZStack {
                        Circle()
                            .scale(x: 1, y: 1)
                            .foregroundColor(ind > self.progress ?
                                             Color(assets.primaryLighterColor) :
                                                Color(assets.primaryColor))
                        Text(String(ind))
                            .font(Font.custom(assets.descriptionFont, size: 12))
                            .foregroundColor(ind > self.progress ?
                                             Color(assets.primaryLightColor) :
                                                Color(assets.buttonTextColor))
                    }.frame(height: 20, alignment: .center)
                    
                    
                    Divider()
                        .rotationEffect(.degrees(90))
                }
            }
            
            ZStack {
                Circle()
                    .scale(x: 1, y: 1)
                    .foregroundColor(numQuestions > self.progress ?
                                     Color(assets.primaryLighterColor) :
                                        Color(assets.primaryColor))
                Image(systemName: "checkmark")
                    .font(Font.custom(assets.descriptionFont, size: 12))
                    .foregroundColor(numQuestions > self.progress ?
                                     Color(assets.primaryLightColor) :
                                        Color(assets.buttonTextColor))
            }.frame(height: 20, alignment: .center)
            
            
            Spacer()
            
        }.frame(height: 45, alignment: .center)
            .padding(.horizontal)
    }
}
