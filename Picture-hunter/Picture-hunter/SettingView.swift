//
//  SettingsView.swift
//  LocationHunter
//
//  Created by cmStudent on 2026/09/30.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var langManager: LanguageManager
    @Binding var selectedDifficulty: Difficulty
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Section Langue
                Section(header: Text(langManager.text(for: "language"))) {
                    Picker(langManager.text(for: "language"), selection: $langManager.selectedLanguage) {
                        ForEach(Language.allCases) { lang in
                            Text(lang.rawValue).tag(lang)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Section Difficulté
                Section(header: Text(langManager.text(for: "difficulty"))) {
                    Picker(langManager.text(for: "difficulty"), selection: $selectedDifficulty) {
                        Text(langManager.text(for: "easy")).tag(Difficulty.easy)
                        Text(langManager.text(for: "medium")).tag(Difficulty.medium)
                        Text(langManager.text(for: "hard")).tag(Difficulty.hard)
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle(langManager.text(for: "settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(langManager.text(for: "close")) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView(selectedDifficulty: .constant(.medium))
        .environmentObject(LanguageManager())
}
