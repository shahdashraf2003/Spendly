//
//  TransactionDetailRow.swift
//  Spendly
//


import SwiftUI

struct TransactionDetailRow: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(SpendlyFont.body)
                .foregroundStyle(Color.spMuted)
            Spacer()
            Text(value)
                .font(SpendlyFont.body)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, SpendlySpacing.md)
    }
}
