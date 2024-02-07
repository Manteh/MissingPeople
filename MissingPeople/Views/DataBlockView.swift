//
//  DataBlockView.swift
//  MissingPeople
//
//  Created by Mantas Simanauskas on 2024-01-28.
//

import SwiftUI

struct DataBlockView: View {
    let highlightColor: HighlightColor
    let icon: Image
    let supportingTitle: String
    let mainTitle: String

    var body: some View {
        HStack(spacing: 10) {
            coloredIconView
            titlesView
        }
    }

    var coloredIconView: some View {
        LinearGradient(
            colors: [highlightColor.color(), highlightColor.secondaryColor()],
            startPoint: .top,
            endPoint: .bottom
        )
        .mask(icon.resizable().scaledToFit())
        .frame(width: 24, alignment: .center)
    }

    var titlesView: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(supportingTitle)
                .font(.system(size: 12, weight: .semibold))
                .opacity(0.2)
            Text(mainTitle)
                .font(.system(size: 14, weight: .semibold))
                .opacity(0.8)
                .multilineTextAlignment(.leading)
        }
    }
}

struct DataBlockStyleView<Content: View>: View {
    let highlightColor: HighlightColor
    let fullWidth: Bool
    @ViewBuilder let content: Content

    var body: some View {
        content
        .padding(.vertical, 15)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.white.opacity(0.02))
                .stroke(RadialGradient(colors: getGradientColors(), center: .center, startRadius: fullWidth ? 140 : 70, endRadius: 0), style: StrokeStyle(lineWidth: 2))
        )
    }

    func getGradientColors() -> [Color] {
        switch highlightColor {
        case .orange:
            return [.red.opacity(0.05), .orange]
        case .blue:
            return [.blue.opacity(0.05), .teal]
        case .none:
            return [.clear, .clear]
        }
    }
}
