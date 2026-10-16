//
//  SettingsView.swift
//  LocationHunter
//
//  Created by cmStudent on 2026/09/30.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var langManager: LanguageManager
    @Environment(\.dismiss) var dismiss
    
    private struct LanguageOption: Identifiable {
        let id = UUID()
        let language: Language
    }
    
    private let languages: [LanguageOption] = [
        LanguageOption(language: .japanese),
        LanguageOption(language: .english),
        LanguageOption(language: .myanmar)
    ]
    
    var body: some View {
        ZStack {
            // Fond dégradé style Arcade
            LinearGradient(
                colors: [Color.black, Color(white: 0.12)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // MARK: - Header
                HStack {
                    Text(langManager.text(for: "settings"))
                        .font(.system(size: 32, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
                
                Spacer()
                
                // MARK: - Titre de Section
                Text(langManager.text(for: "language"))
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
                
                // MARK: - Boutons de Langue (Style Arcade)
                VStack(spacing: 16) {
                    ForEach(languages) { option in
                        let isSelected = (langManager.selectedLanguage == option.language)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                langManager.selectedLanguage = option.language
                            }
                        }) {
                            HStack {
                                Text(option.language.rawValue)
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 28))
                                        .foregroundColor(.green)
                                        .shadow(color: .green.opacity(0.8), radius: 6)
                                }
                            }
                            .padding(.vertical, 18)
                            .padding(.horizontal, 24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.08))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(
                                        isSelected ? Color.blue : Color.white.opacity(0.15),
                                        lineWidth: isSelected ? 3 : 1
                                    )
                            )
                            .shadow(color: isSelected ? Color.blue.opacity(0.5) : Color.clear, radius: 12)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                Spacer()
                Spacer()
            }
        }
    }
}
