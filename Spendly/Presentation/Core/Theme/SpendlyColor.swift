//
//  SpendlyColor.swift
//  Spendly
//
//  ملف الألوان الرئيسي للتطبيق
//  يحتوي على كل الألوان التي يستخدمها التطبيق
//  يدعم الوضع الداكن (Dark Mode) والفاتح (Light Mode) تلقائياً
//

import SwiftUI

// MARK: - SpendlyColor
// هنا نعرّف كل الألوان كـ static properties
// SwiftUI تختار تلقائياً النسخة المناسبة حسب الوضع (داكن/فاتح)

extension Color {

    // MARK: - الخلفيات (Backgrounds)
    
    /// خلفية الشاشة الرئيسية
    /// فاتح: #f4f4f7 | داكن: #0e0e12
    static let spBackground = Color("SpBackground")
    
    /// خلفية البطاقات (Cards)
    /// فاتح: #ffffff | داكن: #1a1a21
    static let spCard = Color("SpCard")
    
    /// لون الفاصل بين العناصر
    /// فاتح: #ececf0 | داكن: #2a2a33
    static let spSeparator = Color("SpSeparator")
    
    /// لون خلفية شريط التقدم (Track)
    /// فاتح: #e8e8ee | داكن: #2c2c36
    static let spTrack = Color("SpTrack")

    // MARK: - ألوان التمييز (Accent)
    
    /// اللون البرتقالي الرئيسي للتطبيق
    /// فاتح: #b25e09 | داكن: #f2a850
    static let spAccent = Color("SpAccent")
    
    /// خلفية عناصر اللون البرتقالي (أفتح منه)
    /// فاتح: #fbeedd | داكن: #3a2a14
    static let spAccentSurface = Color("SpAccentSurface")

    // MARK: - ألوان النص (Text)
    
    /// لون النص الرئيسي
    /// فاتح: #17171c | داكن: #f2f2f6
    static let spForeground = Color("SpForeground")
    
    /// لون النص الثانوي (أقل وضوحاً)
    /// فاتح: #8a8a94 | داكن: #9a9aa6
    static let spMuted = Color("SpMuted")
    
    /// لون نص على خلفية اللون البرتقالي
    /// فاتح: #ffffff | داكن: #1a1206
    static let spOnAccent = Color("SpOnAccent")

    // MARK: - ألوان الحالة (State Colors)
    
    /// أخضر: ضمن الميزانية
    /// فاتح: #1f9d6b | داكن: #4cc995
    static let spSuccess = Color("SpSuccess")
    
    /// برتقالي: قريب من حد الميزانية
    /// فاتح: #c77a00 | داكن: #f0b04a
    static let spWarning = Color("SpWarning")
    
    /// أحمر: تجاوز الميزانية
    /// فاتح: #d6414b | داكن: #ff7a82
    static let spDanger = Color("SpDanger")
}

// MARK: - BudgetStatus
// حالة الميزانية — تحدد اللون حسب النسبة المئوية للإنفاق

enum BudgetStatus {
    case ok      // أقل من 70% — أخضر
    case warning // من 70% إلى 99% — برتقالي
    case over    // 100% وما فوق — أحمر
    
    /// احسب الحالة من نسبة الإنفاق
    static func from(percentage: Double) -> BudgetStatus {
        if percentage >= 100 { return .over }
        if percentage >= 70  { return .warning }
        return .ok
    }
    
    /// اللون المناسب لكل حالة
    var color: Color {
        switch self {
        case .ok:      return .spSuccess
        case .warning: return .spWarning
        case .over:    return .spDanger
        }
    }
    
    /// الأيقونة المناسبة لكل حالة
    var icon: String {
        switch self {
        case .ok:      return "✓"
        case .warning: return "!"
        case .over:    return "✕"
        }
    }
    
    /// النص التوضيحي لكل حالة (يُترجَم لاحقاً)
    var statusKey: String {
        switch self {
        case .ok:      return "budget.status.ok"
        case .warning: return "budget.status.warning"
        case .over:    return "budget.status.over"
        }
    }
}
