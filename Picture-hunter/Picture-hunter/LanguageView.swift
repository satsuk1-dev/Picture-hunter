//
//  LanguageView.swift
//  Picture hunter
//
//  Created by cmStudent on 2026/10/05.
//

import SwiftUI
import Combine

enum Language: String, CaseIterable, Identifiable {
    case japanese = "日本語"
    case english = "English"
    case myanmar = "မြန်မာ"
    
    var id: String { self.rawValue }
}

enum Difficulty: String, CaseIterable, Identifiable {
    case easy, medium, hard
    var id: String { self.rawValue }
}

class LanguageManager: ObservableObject {
    // Le Japonais est désormais la langue principale par défaut
    @Published var selectedLanguage: Language = .japanese
    
    func text(for key: String) -> String {
        switch selectedLanguage {
        case .japanese: return japaneseDictionary[key] ?? key
        case .english: return englishDictionary[key] ?? key
        case .myanmar: return myanmarDictionary[key] ?? key
        }
    }
    
    private let japaneseDictionary: [String: String] = [
        "app_title": "PICTURE HUNTER",
        "subtitle": "学校の文化祭",
        "tap_to_start": "画面をタップしてスタート",
        "start": "スタート",
        "ranking": "ランキング",
        "settings": "設定",
        "language": "言語",
        "difficulty": "難易度",
        "sound": "効果音",
        "easy": "かんたん",
        "medium": "ふつう",
        "hard": "むずかしい",
        "close": "閉じる"
    ]
    
    private let englishDictionary: [String: String] = [
        "app_title": "PICTURE HUNTER",
        "subtitle": "School Festival",
        "tap_to_start": "Tap to Start",
        "start": "START",
        "ranking": "RANKING",
        "settings": "SETTINGS",
        "language": "Language",
        "difficulty": "Difficulty",
        "sound": "Sound Effects",
        "easy": "Easy",
        "medium": "Medium",
        "hard": "Hard",
        "close": "Close"
    ]
    
    private let myanmarDictionary: [String: String] = [
        "app_title": "PICTURE HUNTER",
        "subtitle": "ကျောင်းပွဲတော်",
        "tap_to_start": "စတင်ရန် နှိပ်ပါ",
        "start": "စတင်မည်",
        "ranking": "အဆင့်သတ်မှတ်ချက်",
        "settings": "ဆက်တင်များ",
        "language": "ဘာသာစကား",
        "difficulty": "ခက်ခဲမှုပမာဏ",
        "sound": "အသံစနစ်",
        "easy": "လွယ်ကူသော",
        "medium": "အလယ်အလတ်",
        "hard": "ခက်ခဲသော",
        "close": "ပိတ်မည်"
    ]
}
