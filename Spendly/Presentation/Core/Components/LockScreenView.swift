//
//  LockScreenView.swift
//  Spendly
//
//  Full-screen privacy lock overlay displayed when App Lock is enabled.
//

import SwiftUI

struct LockScreenView: View {

    @Environment(LocalizationManager.self) private var locManager
    @Environment(SettingsManager.self) private var settingsManager

    @State private var errorKey: String?
    @State private var isAuthenticating = false

    var body: some View {
        ZStack {
            Color.spBackground.ignoresSafeArea()

            VStack(spacing: SpendlySpacing.xxl) {
                Spacer()

                // Lock icon — tapping also triggers authentication
                Button {
                    authenticate()
                } label: {
                    Circle()
                        .fill(Color.spAccentSurface)
                        .frame(width: 84, height: 84)
                        .overlay(
                            Image(systemName: settingsManager.faceIDEnabled ? "faceid" : "lock.fill")
                                .font(.system(size: 36, weight: .semibold))
                                .foregroundStyle(Color.spAccent)
                        )
                }
                .buttonStyle(.plain)

                VStack(spacing: SpendlySpacing.xs) {
                    Text(locManager.localize("lock.title"))
                        .font(SpendlyFont.largeTitle)
                        .foregroundStyle(Color.spForeground)

                    Text(locManager.localize("lock.subtitle"))
                        .font(SpendlyFont.body)
                        .foregroundStyle(Color.spMuted)
                        .multilineTextAlignment(.center)
                }

                // Show hint when cancelled, error when failed
                if let errorKey {
                    let isCancelHint = errorKey == "lock.tap_to_retry"
                    Text(locManager.localize(errorKey))
                        .font(SpendlyFont.caption)
                        .foregroundStyle(isCancelHint ? Color.spMuted : Color.spDanger)
                        .multilineTextAlignment(.center)
                        .transition(.opacity)
                }

                Spacer()

                SpendlyButton(
                    locManager.localize("lock.unlock_button"),
                    isLoading: isAuthenticating
                ) {
                    authenticate()
                }
                .padding(.horizontal, SpendlySpacing.xl)
                .padding(.bottom, SpendlySpacing.xxl)
            }
            .padding(.horizontal, SpendlySpacing.xl)
        }
        // Automatically attempt authentication as soon as the lock screen appears
        .task {
            authenticate()
        }
    }

    private func authenticate() {
        guard !isAuthenticating else { return }
        isAuthenticating = true
        errorKey = nil

        Task {
            let failureKey = await settingsManager.unlock(
                reason: locManager.localize("lock.auth_reason")
            )
            withAnimation(.easeInOut(duration: 0.2)) {
                errorKey = failureKey
            }
            isAuthenticating = false
        }
    }
}
