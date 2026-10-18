import Foundation
import SwiftUI
import Combine

// MARK: - Game Modes / ゲームモード定義
enum GameCategory: String, CaseIterable, Identifiable {
    case school = "school"
    case world = "world"
    case halloween = "halloween"
    
    var id: String { rawValue }
}

// MARK: - Quiz Question Data Model / クイズ問題データモデル
struct Question: Identifiable {
    let id = UUID()
    let imageName: String      // Image asset name / Assets内の画像名
    let category: GameCategory // Game Mode / カテゴリ
    let answerJa: [String]    // Japanese correct answers
    let answerEn: [String]    // English correct answers
    let answerMy: [String]    // Myanmar correct answers
    
    var allAnswers: [String] {
        return answerJa + answerEn + answerMy
    }
}

// MARK: - Game Progress Management ViewModel / ゲーム進行管理 ViewModel
class GameModel: ObservableObject {
    @Published var activeQuestions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var currentZoomScale: CGFloat = 5.0
    
    @Published var totalScore: Int = 0          
    @Published var globalTimeRemaining: Int = 60 // 60 secondes
    @Published var correctCount: Int = 0        // Nombre d'images trouvées
    
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isCorrectAnswer: Bool? = nil
    @Published var currentCategory: GameCategory = .school
    
    private var timer: Timer?
    private let minZoomScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.04
    
    private var masterQuestionBank: [Question] = []
    
    init() {
        loadMasterQuestions()
    }
    
    private func loadMasterQuestions() {
        self.masterQuestionBank = [
            // --- MODE SCHOOL (1号館 〜 12号館) ---
            Question(imageName: "school_building_1", category: .school,
                     answerJa: ["1", "1号館", "１号館", "一号館", "いちごうかん", "イチゴウカン", "1gokan", "1 gokan"],
                     answerEn: ["building 1", "building1", "1", "no 1", "no.1"],
                     answerMy: ["၁", "အဆောက်အအုံ ၁"]),

            Question(imageName: "school_building_2", category: .school,
                     answerJa: ["2", "2号館", "２号館", "二号館", "にごうかん", "ニゴウカン", "2gokan", "2 gokan"],
                     answerEn: ["building 2", "building2", "2", "no 2", "no.2"],
                     answerMy: ["၂", "အဆောက်အအုံ ၂"]),

            Question(imageName: "school_building_3", category: .school,
                     answerJa: ["3", "3号館", "３号館", "三号館", "さんごうかん", "サンゴウカン", "3gokan", "3 gokan"],
                     answerEn: ["building 3", "building3", "3", "no 3", "no.3"],
                     answerMy: ["၃", "အဆောက်အအုံ ၃"]),

            Question(imageName: "school_building_4", category: .school,
                     answerJa: ["4", "4号館", "４号館", "四号館", "よんごうかん", "しごうかん", "ヨンゴウカン", "4gokan", "4 gokan"],
                     answerEn: ["building 4", "building4", "4", "no 4", "no.4"],
                     answerMy: ["၄", "အဆောက်အအုံ ၄"]),

            Question(imageName: "school_building_5", category: .school,
                     answerJa: ["5", "5号館", "５号館", "五号館", "ごごうかん", "ゴゴウカン", "5gokan", "5 gokan"],
                     answerEn: ["building 5", "building5", "5", "no 5", "no.5"],
                     answerMy: ["၅", "အဆောက်အအုံ ၅"]),

            Question(imageName: "school_building_6", category: .school,
                     answerJa: ["6", "6号館", "６号館", "六号館", "ろくごうかん", "ロクゴウカン", "6gokan", "6 gokan"],
                     answerEn: ["building 6", "building6", "6", "no 6", "no.6"],
                     answerMy: ["၆", "အဆောက်အအုံ ၆"]),

            Question(imageName: "school_building_7", category: .school,
                     answerJa: ["7", "7号館", "７号館", "七号館", "ななごうかん", "しちごうかん", "ナナゴウカン", "7gokan", "7 gokan"],
                     answerEn: ["building 7", "building7", "7", "no 7", "no.7"],
                     answerMy: ["၇", "အဆောက်အအုံ ၇"]),

            Question(imageName: "school_building_8", category: .school,
                     answerJa: ["8", "8号館", "８号館", "八号館", "はちごうかん", "ハチゴウカン", "8gokan", "8 gokan"],
                     answerEn: ["building 8", "building8", "8", "no 8", "no.8"],
                     answerMy: ["၈", "အဆောက်အအုံ ၈"]),

            Question(imageName: "school_building_9", category: .school,
                     answerJa: ["9", "9号館", "９号館", "九号館", "きゅうごうかん", "くごうかん", "キュウゴウカン", "9gokan", "9 gokan"],
                     answerEn: ["building 9", "building9", "9", "no 9", "no.9"],
                     answerMy: ["၉", "အဆောက်အအုံ ၉"]),

            Question(imageName: "school_building_10", category: .school,
                     answerJa: ["10", "10号館", "１０号館", "十号館", "じゅうごうかん", "ジュウゴウカン", "10gokan", "10 gokan"],
                     answerEn: ["building 10", "building10", "10", "no 10", "no.10"],
                     answerMy: ["၁၀", "အဆောက်အအုံ ၁၀"]),

            Question(imageName: "school_building_11", category: .school,
                     answerJa: ["11", "11号館", "１１号館", "十一号館", "じゅういちごうかん", "ジュウイチゴウカン", "11gokan", "11 gokan"],
                     answerEn: ["building 11", "building11", "11", "no 11", "no.11"],
                     answerMy: ["၁၁", "အဆောက်အအုံ ၁၁"]),

            Question(imageName: "school_building_12", category: .school,
                     answerJa: ["12", "12号館", "１２号館", "十二号館", "じゅうにごうかん", "ジュウニゴウカン", "12gokan", "12 gokan"],
                     answerEn: ["building 12", "building12", "12", "no 12", "no.12"],
                     answerMy: ["၁၂", "အဆောက်အအုံ ၁၂"]),
                     
            // --- MODE WORLD ---
            Question(imageName: "world_eiffel_tower", category: .world,
                     answerJa: ["フランス", "ふらんす"],
                     answerEn: ["France", "france"],
                     answerMy: ["ပြင်သစ်"]),
            Question(imageName: "world_pyramid", category: .world,
                     answerJa: ["エジプト", "えじぷと"],
                     answerEn: ["Egypt", "egypt"],
                     answerMy: ["အီဂျစ်"]),
            Question(imageName: "world_statue_of_liberty", category: .world,
                     answerJa: ["アメリカ", "あめりか", "米国"],
                     answerEn: ["USA", "United States", "America", "usa", "america"],
                     answerMy: ["အမေရိကန်"]),
            Question(imageName: "world_collosseo", category: .world,
                     answerJa: ["イタリア", "いたりあ"],
                     answerEn: ["Italy", "italy"],
                     answerMy: ["အီတလီ"]),
            Question(imageName: "world_fuji_san", category: .world,
                     answerJa: ["日本", "にほん", "ニホン", "にっぽん", "富士山", "ふじさん"],
                     answerEn: ["japan", "Japan", "mt fuji", "mount fuji"],
                     answerMy: ["ဂျပန်"]),
            Question(imageName: "world_merlion", category: .world,
                     answerJa: ["シンガポール", "しんがぽーる"],
                     answerEn: ["singapore", "Singapore"],
                     answerMy: ["စင်ကာပူ"]),
            Question(imageName: "world_sagrada_familia", category: .world,
                     answerJa: ["スペイン", "すぺいん"],
                     answerEn: ["spain", "Spain"],
                     answerMy: ["စပိန်"]),
            Question(imageName: "world_CN_tower", category: .world,
                     answerJa: ["カナダ", "かなだ"],
                     answerEn: ["canada", "Canada"],
                     answerMy: ["ကနေဒါ"]),
            Question(imageName: "world_great_wall", category: .world,
                     answerJa: ["中国", "ちゅうごく"],
                     answerEn: ["china", "China"],
                     answerMy: ["တရုတ်"]),
            Question(imageName: "world_taj_mahal", category: .world,
                     answerJa: ["インド", "いんど"],
                     answerEn: ["india", "India"],
                     answerMy: ["အိန္ဒိယ"]),
            Question(imageName: "world_big_ben", category: .world,
                     answerJa: ["イギリス", "いぎりす", "米国"],
                     answerEn: ["uk","UK", "united kingdom", "england"],
                     answerMy: ["ဗြိတိန်"]),
            Question(imageName: "world_sydney_opera", category: .world,
                     answerJa: ["オーストラリア", "おーすとらりあ"],
                     answerEn: ["australia", "Australia"],
                     answerMy: ["ဩစတြေးလျ"]),
            Question(imageName: "world_christ_redeemer", category: .world,
                     answerJa: ["ブラジル", "ぶらじる"],
                     answerEn: ["brazil", "Brazil"],
                     answerMy: ["ဘရာဇီး"]),
            Question(imageName: "world_shwedagon", category: .world,
                     answerJa: ["ミャンマー", "みゃんまー", "ビルマ"],
                     answerEn: ["myanmar", "burma"],
                     answerMy: ["မြန်မာ"]),
            Question(imageName: "world_switzerland", category: .world,
                     answerJa: ["スイス", "すいす"],
                     answerEn: ["switzerland", "Switzerland"],
                     answerMy: ["ဆူဇာလန်"]),
                     
            // --- MODE HALLOWEEN ---
            Question(imageName: "halloween_jacko", category: .halloween,
                     answerJa: ["かぼちゃ", "カボチャ", "ジャックオーランタン"],
                     answerEn: ["pumpkin", "jack-o'-lantern", "jack o lantern"],
                     answerMy: ["ဖရုံသီး"]),
            Question(imageName: "halloween_witch", category: .halloween,
                     answerJa: ["魔女", "まじょ", "マジョ"],
                     answerEn: ["witch", "witch hat"],
                     answerMy: ["စုန်းမ"]),
            Question(imageName: "halloween_ghost", category: .halloween,
                     answerJa: ["おばけ", "オバケ", "幽霊"],
                     answerEn: ["ghost", "Ghost"],
                     answerMy: ["သရဲ"]),
            Question(imageName: "halloween_bat", category: .halloween,
                     answerJa: ["コウモリ", "こうもり", "バット"],
                     answerEn: ["bat", "Bat"],
                     answerMy: ["လင်းနို့"]),
            Question(imageName: "halloween_candy", category: .halloween,
                     answerJa: ["お菓子", "キャンディ", "飴", "キャンディー", "あめ"],
                     answerEn: ["candy", "sweets"],
                     answerMy: ["မုန့်"]),
            Question(imageName: "halloween_skeleton", category: .halloween,
                     answerJa: ["ガイコツ", "骸骨", "スケルトン", "ほね", "骨"],
                     answerEn: ["skeleton", "bones"],
                     answerMy: ["အရိုးစု"]),
            Question(imageName: "halloween_witch_hat", category: .halloween,
                     answerJa: ["帽子", "魔女の帽子", "ぼうし"],
                     answerEn: ["witch hat", "hat"],
                     answerMy: ["ဦးထုပ်"]),
            Question(imageName: "halloween_cat", category: .halloween,
                     answerJa: ["黒猫", "くろねこ", "クロネコ", "猫", "ねこ"],
                     answerEn: ["black cat", "cat"],
                     answerMy: ["ကြောင်နက်"]),
            Question(imageName: "halloween_haunted_house", category: .halloween,
                     answerJa: ["洋館", "お化け屋敷", "おばけやしき", "館"],
                     answerEn: ["haunted house", "house"],
                     answerMy: ["သရဲအိမ်"]),
            Question(imageName: "halloween_tombstone", category: .halloween,
                     answerJa: ["墓", "墓石", "はか"],
                     answerEn: ["tombstone", "gravestone", "grave"],
                     answerMy: ["သင်္ချိုင်း"]),
            Question(imageName: "halloween_spider_web", category: .halloween,
                     answerJa: ["クモの巣", "蜘蛛の巣", "くものす"],
                     answerEn: ["spider web", "cobweb"],
                     answerMy: ["ပင်ကူအိမ်"]),
            Question(imageName: "halloween_cauldron", category: .halloween,
                     answerJa: ["鍋", "大鍋", "なべ"],
                     answerEn: ["cauldron", "pot"],
                     answerMy: ["မီးဖိုချောင်အိုး"]),
            Question(imageName: "halloween_vampire", category: .halloween,
                     answerJa: ["吸血鬼", "きゅうけつき", "ドラキュラ", "バンパイア"],
                     answerEn: ["vampire", "dracula"],
                     answerMy: ["စုတ်သွေးသရဲ"]),
            Question(imageName: "halloween_candle", category: .halloween,
                     answerJa: ["ローソク", "ろうそく", "キャンドル", "燭台"],
                     answerEn: ["candle", "Candle"],
                     answerMy: ["ဖယောင်းတိုင်"]),
            Question(imageName: "halloween_broom", category: .halloween,
                     answerJa: ["ほうき", "ホウキ", "箒"],
                     answerEn: ["broom", "broomstick"],
                     answerMy: ["တံမြက်စည်း"])
        ]
    }
    
    func setupAndStartGame(category: GameCategory) {
        stopGame()
        
        self.currentCategory = category
        let filtered = masterQuestionBank.filter { $0.category == category }
        self.activeQuestions = filtered.shuffled()
        
        self.currentIndex = 0
        self.totalScore = 0
        self.correctCount = 0
        self.globalTimeRemaining = 60
        self.isGameOver = false
        
        startGlobalTimer()
        startQuestionRound()
    }
    
    var currentQuestion: Question? {
        guard !activeQuestions.isEmpty else { return nil }
        return activeQuestions[currentIndex % activeQuestions.count]
    }
    
    private func startGlobalTimer() {
        isPlaying = true
        timer?.invalidate()
        
        var subTickCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            // ズームアウト
            if self.currentZoomScale > self.minZoomScale {
                self.currentZoomScale -= self.zoomStep
            }
            
            // カウントダウン
            subTickCount += 1
            if subTickCount >= 10 {
                subTickCount = 0
                if self.globalTimeRemaining > 1 {
                    self.globalTimeRemaining -= 1
                } else {
                    self.globalTimeRemaining = 0
                    self.finishGame()
                }
            }
        }
    }
    
    private func startQuestionRound() {
        isCorrectAnswer = nil
        currentZoomScale = 5.0
    }
    
    func stopGame() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    private func finishGame() {
        stopGame()
        isGameOver = true
    }
    
    func checkAnswer(_ input: String) -> Bool {
        guard let question = currentQuestion, isPlaying else { return false }
        
        let validAnswers = question.allAnswers
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = validAnswers.contains { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == formattedInput
        }
        
        if isCorrect {
            isCorrectAnswer = true
            correctCount += 1
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if self.isPlaying {
                    self.nextQuestion()
                }
            }
            return true
        } else {
            isCorrectAnswer = false
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if self.isCorrectAnswer == false {
                    self.isCorrectAnswer = nil
                }
            }
            return false
        }
    }
    
    func nextQuestion() {
        currentIndex += 1
        if currentIndex >= activeQuestions.count {
            activeQuestions.shuffle()
            currentIndex = 0
        }
        startQuestionRound()
    }
    
    func skipQuestion() {
        guard isPlaying else { return }
        nextQuestion()
    }
}
