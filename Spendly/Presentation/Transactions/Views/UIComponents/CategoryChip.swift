//
//  CategoryChip.swift
//  Spendly
//

import SwiftUI

struct CategoryChip: View {

    let category: Category
    let isSelected: Bool
    let action: () -> Void

    @Environment(LocalizationManager.self) private var locManager

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendlySpacing.xs) {
                Text(category.icon)
                Text(category.localizedName(using: locManager))
                    .font(SpendlyFont.body)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, SpendlySpacing.sm)
            .background(isSelected ? Color.spAccent : Color.spCard)
            .foregroundStyle(isSelected ? Color.spOnAccent : Color.spForeground)
            .clipShape(Capsule())
        }
    }
}
