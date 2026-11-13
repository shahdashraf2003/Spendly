//
//  LocalizationManager.swift
//  Spendly
//


import SwiftUI
import Observation

	/// `CaseIterable` auto-generates `allCases`, an array of every case,
	/// which lets us build the language picker with `ForEach(AppLanguage.allCases)`.
	/// Adding a new language here makes it appear in the picker automatically.
enum AppLanguage: String, CaseIterable {
    case english = "en"
    case arabic  = "ar"

    var displayName: String {
        switch self {
        case .english: return "English"
        case .arabic:  return "العربية"
        }
    }


    var isRTL: Bool {
        return self == .arabic
    }

    var layoutDirection: LayoutDirection {
        return isRTL ? .rightToLeft : .leftToRight
    }
}

// MARK: - LocalizationManager


@MainActor
@Observable
final class LocalizationManager {


    private(set) var language: AppLanguage

    private let storageKey = "spendly_language"

    init() {

        if let savedCode = UserDefaults.standard.string(forKey: "spendly_language"),
           let saved = AppLanguage(rawValue: savedCode) {
            self.language = saved
        } else {

            let deviceLang = Locale.current.language.languageCode?.identifier ?? "en"
            self.language = deviceLang == "ar" ? .arabic : .english
        }
    }
    

    func setLanguage(_ newLanguage: AppLanguage) {
        language = newLanguage
        UserDefaults.standard.set(newLanguage.rawValue, forKey: storageKey)
    }
    

    func localize(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: language.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }

    /// مثال: localize("budget.of %@", args: "500") → "of 500"
    func localize(_ key: String, args: CVarArg...) -> String {
        let format = localize(key)
        return String(format: format, arguments: args)
    }
}

extension String {

    func localized(using manager: LocalizationManager) -> String {
        manager.localize(self)
    }
}

// MARK: - View Extension

extension View {

    func layoutDirection(for manager: LocalizationManager) -> some View {
        self.environment(\.layoutDirection, manager.language.layoutDirection)
    }
}

// MARK: - Category Localization Extension

extension Category {

    func localizedName(using manager: LocalizationManager) -> String {
        switch name.lowercased() {
        case "food", "الطعام", "category.food":
            return manager.localize("category.food")
        case "shopping", "التسوق", "category.shopping":
            return manager.localize("category.shopping")
        case "transportation", "المواصلات", "category.transport":
            return manager.localize("category.transport")
        case "bills", "الفواتير", "category.bills":
            return manager.localize("category.bills")
        case "entertainment", "الترفيه", "category.entertainment":
            return manager.localize("category.entertainment")
        case "income", "الدخل", "category.income":
            return manager.localize("category.income")
        case "other", "أخرى", "category.other":
            return manager.localize("category.other")
        default:
            return manager.localize(name)
        }
    }
}
