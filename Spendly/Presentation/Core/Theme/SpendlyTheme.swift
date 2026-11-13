//
//  SpendlyTheme.swift
//  Spendly
//
//  ملف الثيم الرئيسي: يجمع الخطوط، الأشكال، والمسافات
//  الهدف: توحيد الشكل العام للتطبيق في مكان واحد
//

import SwiftUI

// MARK: - SpendlyFont
// نظام الخطوط — بدل ما تكتب fontSize في كل مكان، استخدم هنا

enum SpendlyFont {
    
    // MARK: - أحجام النصوص
    
    /// رقم كبير (الرصيد، المبالغ الكبيرة) — 36pt Bold
    static let displayLarge: Font = .system(size: 36, weight: .bold, design: .rounded)
    
    /// رقم متوسط (المبالغ في البطاقات) — 24pt Bold
    static let displayMedium: Font = .system(size: 24, weight: .bold, design: .rounded)
    
    /// عنوان الشاشة — 30pt Bold
    static let largeTitle: Font = .system(size: 30, weight: .bold, design: .default)
    
    /// عنوان القسم — 17pt Semibold
    static let sectionTitle: Font = .system(size: 17, weight: .semibold)
    
    /// نص عادي كبير — 16pt Regular
    static let bodyLarge: Font = .system(size: 16, weight: .regular)
    
    /// نص عادي — 14pt Regular
    static let body: Font = .system(size: 14, weight: .regular)
    
    /// نص صغير (النصوص الثانوية) — 13pt Regular
    static let caption: Font = .system(size: 13, weight: .regular)
    
    /// نص صغير جداً (الـ Labels) — 12pt Semibold
    static let label: Font = .system(size: 12, weight: .semibold)
}

// MARK: - SpendlyShape
// الأشكال المستخدمة في التطبيق (زوايا البطاقات، الأزرار...)

enum SpendlyShape {
    
    /// زاوية البطاقة الكبيرة (Card)
    static let cardRadius: CGFloat = 20
    
    /// زاوية الأيقونة الصغيرة
    static let iconRadius: CGFloat = 12
    
    /// زاوية الزر الكبير
    static let buttonRadius: CGFloat = 16
    
    /// زاوية الـ Bottom Sheet
    static let sheetRadius: CGFloat = 26
    
    /// زاوية الـ Toast (الإشعار السريع)
    static let toastRadius: CGFloat = 14
    
    /// زاوية الـ Chip (وسوم الفلتر)
    static let chipRadius: CGFloat = 99
}

// MARK: - SpendlySpacing
// المسافات الموحّدة في التطبيق

enum SpendlySpacing {
    
    /// مسافة صغيرة جداً بين العناصر المتقاربة
    static let xs: CGFloat = 4
    
    /// مسافة صغيرة
    static let sm: CGFloat = 8
    
    /// مسافة متوسطة (الأكثر استخداماً)
    static let md: CGFloat = 12
    
    /// مسافة كبيرة
    static let lg: CGFloat = 16
    
    /// مسافة كبيرة جداً (padding الشاشة)
    static let xl: CGFloat = 18
    
    /// مسافة ضخمة (بين الأقسام)
    static let xxl: CGFloat = 24
}

// MARK: - SpendlyShadow
// الظلال المستخدمة في البطاقات

struct SpendlyShadow: ViewModifier {
    
    /// ظل خفيف للبطاقات العادية
    static let card = SpendlyShadow(
        color: .black.opacity(0.05),
        radius: 3,
        x: 0,
        y: 1
    )
    
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
    
    func body(content: Content) -> some View {
        content.shadow(color: color, radius: radius, x: x, y: y)
    }
}

extension View {
    /// أضف ظل البطاقة القياسي
    func cardShadow() -> some View {
        modifier(SpendlyShadow.card)
    }
}
