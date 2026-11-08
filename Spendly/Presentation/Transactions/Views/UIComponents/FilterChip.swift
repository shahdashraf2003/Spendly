//
//  FilterChip.swift
//  Spendly
//

import SwiftUI

struct FilterChip: View {

    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SpendlyFont.body)
                .padding(.horizontal, 14)
                .padding(.vertical, SpendlySpacing.sm)
                .background(isSelected ? Color.spAccent : Color.spCard)
                .foregroundStyle(isSelected ? Color.spOnAccent : Color.spForeground)
                .clipShape(Capsule())
        }
    }
}
