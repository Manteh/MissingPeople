//
//  HighlightColor.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

enum HighlightColor {
    case orange
    case blue
    case none

    func color() -> Color {
        switch self {
        case .orange:
            return .orange
        case .blue:
            return .teal
        case .none:
            return .clear
        }
    }

    func secondaryColor() -> Color {
        switch self {
        case .orange:
            return .red.opacity(0.5)
        case .blue:
            return .blue.opacity(0.5)
        case .none:
            return .clear
        }
    }
}
