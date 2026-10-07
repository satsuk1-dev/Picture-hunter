//
//  PictureHunterApp.swift
//  PictureHunter
//
//  Created by cmStudent on 2026/09/28.
//

import SwiftUI

@main
struct PictureHunterApp: App {
    @StateObject private var langManager = LanguageManager()
    @StateObject private var scoreManager = ScoreManager()
    
    @State private var isFinishedSplash = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isFinishedSplash {
                    NavigationStack {
                        ContentView(isFinishedSplash: $isFinishedSplash)
                    }
                    .transition(.opacity)
                } else {
                    WelcomeView(isFinished: $isFinishedSplash)
                        .transition(.opacity)
                }
            }
            .environmentObject(langManager)
            .environmentObject(scoreManager)
        }
    }
}
