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
    
    // Variable pour savoir si l'utilisateur a appuyé sur le premier écran
    @State private var isFinishedSplash = false

    var body: some Scene {
        WindowGroup {
            ZStack {
                if isFinishedSplash {
                    // Écran principal (Menu) avec la navigation
                    NavigationStack {
                        ContentView(isFinishedSplash: $isFinishedSplash)
                    }
                    .transition(.opacity)
                } else {
                    // Premier écran au lancement de l'application
                    WelcomeView(isFinished: $isFinishedSplash)
                        .transition(.opacity)
                }
            }
            .environmentObject(langManager)
        }
    }
}
