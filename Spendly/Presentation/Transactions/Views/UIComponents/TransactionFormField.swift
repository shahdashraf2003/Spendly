//
//  TransactionFormField.swift
//  Spendly
//

import SwiftUI
/// حاوية موحّدة لحقول النموذج: عنوان + محتوى
struct TransactionFormField<Content: View>: View {

    let label: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            Text(label)
                .font(SpendlyFont.caption)
                .foregroundStyle(Color.spMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
    }
}
