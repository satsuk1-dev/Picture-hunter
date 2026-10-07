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
        "subtitle": "日専祭",
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
        "close": "閉じる",
        
        // Mode Selection / モード選択
        "select_mode": "モードを選択",
        "subtitle_mode": "テーマを選んでゲームをスタート！",
        "mode_school": "学校",
        "subtitle_school": "文房具・教室の物",
        "mode_world": "世界",
        "subtitle_world": "世界の有名スポット",
        "mode_japan": "日本",
        "subtitle_japan": "日本の文化と名所",
        "mode_halloween": "ハロウィン",
        "subtitle_halloween": "期間限定イベント",
        
        // In-game
        "score": "スコア",
        "no_score": "まだ記録がありません",
        "pts": "pt",
        "type_answer": "回答を入力...",
        "pause": "一時停止",
        "resume": "再開",
        "correct": "正解！",
        "incorrect": "不正解...もう一度！",
        "enter_name_title": "スコア登録",
        "enter_name_message": "ランキングに登録するニックネームを入力してください",
        "name_placeholder": "ニックネーム",
        "save_button": "登録"
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
        "close": "Close",
        
        // Mode Selection
        "select_mode": "Select Game Mode",
        "subtitle_mode": "Choose a topic to start playing!",
        "mode_school": "School",
        "subtitle_school": "Classroom items",
        "mode_world": "World",
        "subtitle_world": "Famous landmarks",
        "mode_japan": "Japan",
        "subtitle_japan": "Culture & sights",
        "mode_halloween": "Halloween 🎃",
        "subtitle_halloween": "Spooky event",
        
        // In-game
        "score": "Score",
        "no_score": "No scores yet",
        "pts": "pts",
        "type_answer": "Type answer...",
        "pause": "PAUSE",
        "resume": "RESUME",
        "correct": "Correct!",
        "incorrect": "Incorrect... Try again!",
        
        // Name entry
        "enter_name_title": "Save Score",
        "enter_name_message": "Enter your nickname for the ranking",
        "name_placeholder": "Nickname",
        "save_button": "Save"
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
        "close": "ပိတ်မည်",
        
        // Mode Selection
        "select_mode": "ဂိမ်းမုဒ်ကို ရွေးပါ",
        "subtitle_mode": "ကစားရန် ခေါင်းစဉ်တစ်ခုကို ရွေးပါ",
        "mode_school": "ကျောင်း",
        "subtitle_school": "စာသင်ခန်းသုံးပစ္စည်းများ",
        "mode_world": "ကမ္ဘာ",
        "subtitle_world": "ကမ္ဘာကျော်နေရာများ",
        "mode_japan": "ဂျပန်",
        "subtitle_japan": "ဂျပန်ယဉ်ကျေးမှုနှင့် နေရာများ",
        "mode_halloween": "ဟောလိုးဝင်း 🎃",
        "subtitle_halloween": "သရဲပွဲတော် အထူးမုဒ်",
        
        // In-game
        "score": "ရမှတ်",
        "no_score": "မှတ်တမ်းမရှိသေးပါ",
        "pts": "မှတ်",
        "type_answer": "အဖြေရိုက်ထည့်ပါ...",
        "pause": "ခေတ္တရပ်မည်",
        "resume": "ပြန်စမည်",
        "correct": "မှန်ကန်သည်!",
        "incorrect": "မှားယွင်းသည်...",
        
        // Name entry
        "enter_name_title": "မှတ်တမ်းသိမ်းမည်",
        "enter_name_message": "အဆင့်သတ်မှတ်ချက်အတွက် နာမည်ထည့်ပါ",
        "name_placeholder": "အမည်",
        "save_button": "သိမ်းမည်"
    ]
}
