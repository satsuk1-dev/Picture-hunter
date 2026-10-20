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
        "subtitle": "クローズアウトしていく画像から答えをすばやく推測！\nわかった瞬間にすぐ回答して高得点を狙おう！",
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
        
        "select_mode": "モードを選択",
        "subtitle_mode": "テーマを選んでゲームをスタート！",
        "mode_school": "学校",
        "subtitle_school": "校内スポット・教室の物",
        "mode_world": "世界",
        "subtitle_world": "世界の有名スポット",
        "mode_japan": "日本",
        "subtitle_japan": "日本の文化と名所",
        "mode_halloween": "ハロウィン",
        "subtitle_halloween": "期間限定イベント",
        
        "question_school": "この建物は何号館ですか？",
        "question_world": "この写真はどこの国ですか？",
        "question_halloween": "これは何ですか？",
        
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
        "save_button": "登録",
        
        // --- Poubelle / Clean Scores (3 Langues) ---
        "delete_ranking_title": "ランキングの削除",
        "delete_ranking_message": "削除するデータの範囲を選択してください。",
        "delete_this_category": "このカテゴリのみ削除",
        "delete_all_rankings": "すべてのランキングを削除",
        "cancel": "キャンセル"
    ]
    
    private let englishDictionary: [String: String] = [
        "app_title": "PICTURE HUNTER",
        "subtitle": "Guess the answer fast as the photo zooms out!\nAnswer the moment you know it and aim for a high score!",
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
        
        "select_mode": "Select Game Mode",
        "subtitle_mode": "Choose a topic to start playing!",
        "mode_school": "School",
        "subtitle_school": "School spots & items",
        "mode_world": "World",
        "subtitle_world": "Famous landmarks",
        "mode_japan": "Japan",
        "subtitle_japan": "Culture & sights",
        "mode_halloween": "Halloween",
        "subtitle_halloween": "Spooky event",
        
        "question_school": "Which building number is this?",
        "question_world": "Which country is this photo from?",
        "question_halloween": "What is this?",
        
        "score": "Score",
        "no_score": "No scores yet",
        "pts": "pts",
        "type_answer": "Type answer...",
        "pause": "PAUSE",
        "resume": "RESUME",
        "correct": "Correct!",
        "incorrect": "Incorrect... Try again!",
        
        "enter_name_title": "Save Score",
        "enter_name_message": "Enter your nickname for the ranking",
        "name_placeholder": "Nickname",
        "save_button": "Save",
        
        // --- Poubelle / Clean Scores (3 Langues) ---
        "delete_ranking_title": "Delete Ranking",
        "delete_ranking_message": "Please select the range of data to delete.",
        "delete_this_category": "Delete only this category",
        "delete_all_rankings": "Delete all rankings",
        "cancel": "Cancel"
    ]
    
    private let myanmarDictionary: [String: String] = [
        "app_title": "PICTURE HUNTER",
        "subtitle": "ဓာတ်ပုံ ဖြည်းဖြည်းချင်း ကျယ်လာတာကို ကြည့်ပြီး အဖြေကို အမြန်ခန့်မှန်းပါ!\nသိတာနဲ့ ချက်ချင်းဖြေပြီး ရမှတ်မြင့်မြင့် ရအောင် ကြိုးစားပါ!",
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
        
        "select_mode": "ဂိမ်းမုဒ်ကို ရွေးပါ",
        "subtitle_mode": "ကစားရန် ခေါင်းစဉ်တစ်ခုကို ရွေးပါ",
        "mode_school": "ကျောင်း",
        "subtitle_school": "ကျောင်းတွင်းနေရာများနှင့် ပစ္စည်းများ",
        "mode_world": "ကမ္ဘာ",
        "subtitle_world": "ကမ္ဘာကျော်နေရာများ",
        "mode_japan": "ဂျပန်",
        "subtitle_japan": "ဂျပန်ယဉ်ကျေးမှုနှင့် နေရာများ",
        "mode_halloween": "ဟောလိုးဝင်း",
        "subtitle_halloween": "သရဲပွဲတော် အထူးမုဒ်",
        
        "question_school": "ဒီအဆောက်အအုံက အဆောက်အအုံနံပါတ် ဘယ်လောက်လဲ။",
        "question_world": "ဒီဓာတ်ပုံက ဘယ်နိုင်ငံလဲ။",
        "question_halloween": "ဒါဘာလဲ။",
        
        "score": "ရမှတ်",
        "no_score": "မှတ်တမ်းမရှိသေးပါ",
        "pts": "မှတ်",
        "type_answer": "အဖြေရိုက်ထည့်ပါ...",
        "pause": "ခေတ္တရပ်မည်",
        "resume": "ပြန်စမည်",
        "correct": "မှန်ကန်သည်!",
        "incorrect": "မှားယွင်းသည်...",
        
        "enter_name_title": "မှတ်တမ်းသိမ်းမည်",
        "enter_name_message": "အဆင့်သတ်မှတ်ချက်အတွက် နာမည်ထည့်ပါ",
        "name_placeholder": "အမည်",
        "save_button": "သိမ်းမည်",
        
        // --- Poubelle / Clean Scores (3 Langues) ---
        "delete_ranking_title": "အဆင့်သတ်မှတ်ချက် ဖျက်မည်",
        "delete_ranking_message": "ဖျက်လိုသော အချက်အလက်အမျိုးအစားကို ရွေးချယ်ပါ",
        "delete_this_category": "ဒီကဏ္ဍတစ်ခုတည်းကိုသာ ဖျက်မည်",
        "delete_all_rankings": "အဆင့်သတ်မှတ်ချက်အားလုံး ဖျက်မည်",
        "cancel": "မလုပ်တော့ပါ"
    ]
}
