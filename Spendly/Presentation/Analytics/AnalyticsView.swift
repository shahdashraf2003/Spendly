//
//  AnalyticsView.swift
//  Spendly
//


import SwiftUI
import Charts


enum AnalyticsPeriod: String, CaseIterable {
    case week  = "week"
    case month = "month"
    case year  = "year"
    
    var locKey: String {
        switch self {
        case .week:  return "analytics.period.week"
        case .month: return "analytics.period.month"
        case .year:  return "analytics.period.year"
        }
    }
}

// MARK: - AnalyticsView

struct AnalyticsView: View {
    

    
    let transactions: [Transaction]
    let categories: [Category]
    
    @State private var selectedPeriod = AnalyticsPeriod.month
    
    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager
    

    private var expensesByCategory: [(Category, Decimal)] {
        categories
            .filter { $0.type == .expense }
            .compactMap { cat -> (Category, Decimal)? in
                let spent = transactions
                    .filter { $0.type == .expense && $0.categoryID == cat.id }
                    .reduce(Decimal(0)) { $0 + $1.amount }
                return spent > 0 ? (cat, spent) : nil
            }
            .sorted { $0.1 > $1.1 }
    }
    

    private var totalExpenses: Decimal {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }
    

    private var totalIncome: Decimal {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }
    

    private let chartColors: [Color] = [
        .spAccent,
        Color(red: 0.23, green: 0.49, blue: 0.64),
        Color(red: 0.23, green: 0.65, blue: 0.63),
        Color(red: 0.48, green: 0.56, blue: 0.23),
        Color(red: 0.72, green: 0.42, blue: 0.69)
    ]

    private var barData: [Double] {
        switch selectedPeriod {
        case .week:  return [40, 65, 30, 80, 55, 90, 45]
        case .month: return [30, 50, 45, 70, 60, 85, 55, 40, 65, 72, 48, 90, 55, 62, 78, 45, 50, 68, 74, 55, 80, 66, 45, 58, 72, 60, 48, 85, 70, 55]
        case .year:  return [55, 40, 65, 50, 75, 60, 80, 70, 45, 85, 60, 50]
        }
    }
    

    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                

                Text(locManager.localize("analytics.title"))
                    .font(SpendlyFont.largeTitle)
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 8)
                

                periodSegment
                    .padding(.horizontal, SpendlySpacing.xl)
                    .padding(.top, 12)
                

                trendChart
                    .padding(.top, SpendlySpacing.xl)
                

                breakdownChart
                    .padding(.top, SpendlySpacing.xl)
                

                summaryNumbers
                    .padding(.top, SpendlySpacing.xl)
                

                insightCard
                    .padding(.top, SpendlySpacing.sm)
                    .padding(.bottom, SpendlySpacing.xxl)
            }
        }
        .background(Color.spBackground)
    }
    

    
    private var periodSegment: some View {
        HStack(spacing: 3) {
            ForEach(AnalyticsPeriod.allCases, id: \.self) { period in
                Button {
                    withAnimation { selectedPeriod = period }
                } label: {
                    Text(locManager.localize(period.locKey))
                        .font(SpendlyFont.body)
                        .fontWeight(selectedPeriod == period ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 7)
                        .background(selectedPeriod == period ? Color.spCard : Color.clear)
                        .foregroundStyle(selectedPeriod == period ? Color.spForeground : Color.spMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 9))
                }
            }
        }
        .padding(3)
        .background(Color.spTrack)
        .clipShape(RoundedRectangle(cornerRadius: 11))
    }
    
    // MARK: - المخطط الشريطي
    
    private var trendChart: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("analytics.trend"))
                .font(SpendlyFont.sectionTitle)
                .padding(.horizontal, SpendlySpacing.xl)
            
            SpendlyCard {
                // مخطط شريطي بسيط باستخدام GeometryReader
                GeometryReader { geo in
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(Array(barData.enumerated()), id: \.offset) { _, value in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.spAccent)
                                .frame(
                                    width: max(4, (geo.size.width - CGFloat(barData.count - 1) * 4) / CGFloat(barData.count)),
                                    height: geo.size.height * CGFloat(value / 100.0)
                                )
                        }
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                }
                .frame(height: 110)
            }
            .padding(.horizontal, SpendlySpacing.xl)
        }
    }
    
    // MARK: - المخطط الدائري (Category Breakdown)
    
    private var breakdownChart: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(locManager.localize("analytics.breakdown"))
                .font(SpendlyFont.sectionTitle)
                .padding(.horizontal, SpendlySpacing.xl)
            
            SpendlyCard {
                HStack(spacing: SpendlySpacing.lg) {
                    
                    // المخطط الدائري
                    ZStack {
                        if #available(iOS 16.0, *) {
                            Chart(Array(expensesByCategory.enumerated()), id: \.offset) { idx, item in
                                SectorMark(
                                    angle: .value(locManager.localize("general.amount"), Double(truncating: item.1 as NSDecimalNumber)),
                                    innerRadius: .ratio(0.55),
                                    angularInset: 2
                                )
                                .foregroundStyle(chartColors[idx % chartColors.count])
                            }
                            .frame(width: 120, height: 120)
                        } else {
                            Circle()
                                .strokeBorder(Color.spTrack, lineWidth: 2)
                                .frame(width: 120, height: 120)
                        }
                    }
                    
                    // قائمة الفئات مع النسبة
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(Array(expensesByCategory.prefix(5).enumerated()), id: \.offset) { idx, item in
                            HStack(spacing: SpendlySpacing.xs) {
                                Circle()
                                    .fill(chartColors[idx % chartColors.count])
                                    .frame(width: 10, height: 10)
                                
                                Text(item.0.localizedName(using: locManager))
                                    .font(SpendlyFont.caption)
                                    .foregroundStyle(Color.spForeground)
                                
                                Spacer()
                                
                                Text(percentage(item.1))
                                    .font(SpendlyFont.caption)
                                    .fontWeight(.bold)
                            }
                        }
                        
                        if expensesByCategory.isEmpty {
                            Text(locManager.localize("general.no_data"))
                                .font(SpendlyFont.caption)
                                .foregroundStyle(Color.spMuted)
                        }
                    }
                }
            }
            .padding(.horizontal, SpendlySpacing.xl)
        }
    }
    
    // MARK: - أرقام الملخص
    
    private var summaryNumbers: some View {
        HStack(spacing: SpendlySpacing.sm) {
            SpendlyCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(locManager.localize("analytics.net_savings"))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                    Text(formatAmount(totalIncome - totalExpenses))
                        .font(SpendlyFont.displayMedium)
                        .foregroundStyle(Color.spSuccess)
                }
            }
            
            SpendlyCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(locManager.localize("analytics.avg_daily"))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(Color.spMuted)
                    Text(formatAmount(totalExpenses / 30))
                        .font(SpendlyFont.displayMedium)
                        .foregroundStyle(Color.spForeground)
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
    }
    
    
    private var insightCard: some View {
        SpendlyCard {
            HStack(spacing: SpendlySpacing.sm) {
                Text("💡")
                    .font(.system(size: 20))
                Text(locManager.localize("analytics.insight"))
                    .font(SpendlyFont.caption)
                    .foregroundStyle(Color.spMuted)
            }
        }
        .padding(.horizontal, SpendlySpacing.xl)
    }
    

    private func percentage(_ amount: Decimal) -> String {
        guard totalExpenses > 0 else { return "0%" }
        let pct = Double(truncating: (amount / totalExpenses * 100) as NSDecimalNumber)
        return "\(Int(pct))%"
    }
    
    private func formatAmount(_ amount: Decimal) -> String {
        let abs = amount < 0 ? -amount : amount
        return "\(abs.formatted(.number.precision(.fractionLength(0)))) \(settingsManager.currencySymbol(using: locManager))"
    }
}
