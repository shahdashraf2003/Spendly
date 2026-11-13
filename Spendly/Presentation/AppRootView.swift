//
//  AppRootView.swift
//  Spendly
//
//  Created by Shahudaa on 20/10/2026.
//


import SwiftUI
import SwiftData

struct AppRootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var appContainer: AppContainer?

    var body: some View {
        Group {
            if let appContainer {
                ContentView(appContainer: appContainer)
            } else {
                ProgressView()
            }
        }
        .task {
            if appContainer == nil {
                appContainer = AppContainer(
                    modelContext: modelContext
                )
            }
        }
    }
}