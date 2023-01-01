//
//  ViewAssets.swift
//  PersonalizationKit
//
//  Created by Daniya on 28/06/2022.
//

import SwiftUI

public protocol PersonalizationAssets {
    var titleFont: String { get }
    var descriptionFont: String { get }
    var primaryColor: UIColor { get }
    var primaryTextColor: UIColor { get }
    var secondaryTextColor: UIColor { get }
    var buttonTextColor: UIColor { get }
    var borderColor: UIColor { get }
}
