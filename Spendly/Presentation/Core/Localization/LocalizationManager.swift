//
//  LocalizationManager.swift
//  Spendly
//
//  مدير الترجمة — يتحكم في لغة التطبيق (عربي/إنجليزي)
//
//  كيف يعمل:
//  1. يخزن اللغة المختارة في UserDefaults (تُحفظ حتى بعد إغلاق التطبيق)
//  2. يُستخدَم كـ EnvironmentObject ليكون متاحاً في كل الشاشات
//  3. عند تغيير اللغة، يُعيد بناء الواجهة تلقائياً عبر @Observable
//

import SwiftUI
import Observation

// MARK: - AppLanguage
// التعداد (enum) الذي يمثل اللغات المتاحة

enum AppLanguage: String, CaseIterable {
    case english = "en"  // الإنجليزية
    case arabic  = "ar"  // العربية
    
    /// الاسم الظاهر في الإعدادات
    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic:  return "العربية"
        }
    }
    
    /// هل اللغة من اليمين لليسار؟
    /// العربية RTL، الإنجليزية LTR
    var isRTL: Bool {
        return self == .arabic
    }
    
    /// اتجاه التخطيط المناسب للـ SwiftUI
    var layoutDirection: LayoutDirection {
        return isRTL ? .rightToLeft : .leftToRight
    }
}

// MARK: - LocalizationManager
// الكلاس الرئيسي لإدارة الترجمة

@MainActor
@Observable
final class LocalizationManager {
    
    // MARK: - الخصائص
    
    /// اللغة الحالية — أي تغيير هنا يُحدّث الواجهة تلقائياً
    private(set) var language: AppLanguage
    
    /// مفتاح التخزين في UserDefaults
    private let storageKey = "spendly_language"
    
    // MARK: - التهيئة
    
    init() {
        // اقرأ اللغة المحفوظة، أو استخدم لغة الجهاز كافتراضية
        if let savedCode = UserDefaults.standard.string(forKey: "spendly_language"),
           let saved = AppLanguage(rawValue: savedCode) {
            self.language = saved
        } else {
            // تحقق من لغة الجهاز الافتراضية
            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.language = deviceLang == "ar" ? .arabic : .english
        }
    }
    
    // MARK: - الدوال
    
    /// غيّر لغة التطبيق واحفظها
    func setLanguage(_ newLanguage: AppLanguage) {
        language = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: storageKey)
    }
    
    /// ترجم مفتاحاً نصياً حسب اللغة الحالية
    /// مثال: localize("tab.home") → "Home" أو "الرئيسية"
    func localize(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key  // إذا فشل، أعد المفتاح كما هو
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    /// ترجم مفتاحاً مع إدراج قيمة متغيرة
    /// مثال: localize("budget.of %@", args: "500") → "of 500"
    func localize(_ key: String, args: CVarArg...) -> String {
        let format = localize(key)
        return String(format: format, arguments: args)
    }
}

// MARK: - String Extension
// امتداد على String لتسهيل الترجمة

extension String {
    /// ترجم المفتاح إلى النص المناسب حسب اللغة
    /// الاستخدام: "tab.home".localized(using: locManager)
    func localized(using manager: LocalizationManager) -> String {
        manager.localize(self)
    }
}

// MARK: - View Extension
// امتداد على View لتطبيق اتجاه الواجهة

extension View {
    /// طبّق اتجاه RTL/LTR حسب اللغة
    func layoutDirection(for manager: LocalizationManager) -> some View {
        self.environment(\.layoutDirection, manager.language.layoutDirection)
    }
}
