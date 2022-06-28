//
//  ViewAssets.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

protocol PersonalizationAssets {
    var titleFont: String { get }
    var descriptionFont: String { get }
    var mainTextColor: UIColor { get }
    var descriptionTextColor: UIColor { get }
    var detailsTextColor: UIColor { get }
    var copyrightTextColor: UIColor { get }
    var placeholderTextColor: UIColor { get }
    var primaryColor: UIColor { get }
    var primaryLightColor: UIColor { get }
    var primaryLighterColor: UIColor { get }
    var buttonTextColor: UIColor { get }
    var borderColor: UIColor { get }
    var completeProgressColor: UIColor { get }
    var pinkAccentColor: UIColor { get }
    var successMain: Color { get }
    var successLighter: Color { get }
    var errorMain: Color { get }
    var errorLighter: Color { get }
    var checkboxFull: String { get }
    var checkboxEmpty: String { get }
}
