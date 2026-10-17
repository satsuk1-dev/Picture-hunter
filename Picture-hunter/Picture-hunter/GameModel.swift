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
    
    @Published var totalScore: Int = 0          // Score total (100 pts par image)
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
            // --- MODE SCHOOL ---
            Question(imageName: "school_pencil", category: .school,
                     answerJa: ["鉛筆", "えんぴつ", "エンピツ"],
                     answerEn: ["pencil", "Pencil"],
                     answerMy: ["ခဲတံ"]),
            Question(imageName: "school_desk", category: .school,
                     answerJa: ["机", "つくえ", "ツクエ"],
                     answerEn: ["desk", "Desk"],
                     answerMy: ["စာပွဲ"]),
            Question(imageName: "school_eraser", category: .school,
                     answerJa: ["消しゴム", "けしごむ"],
                     answerEn: ["eraser", "rubber"],
                     answerMy: ["ခဲဖျက်"]),
            Question(imageName: "school_blackboard", category: .school,
                     answerJa: ["黒板", "こくばん"],
                     answerEn: ["blackboard", "chalkboard"],
                     answerMy: ["ကျောက်သင်ပုန်း"]),
                     
            // --- MODE WORLD ---
            Question(imageName: "eiffel_tower", category: .world,
                     answerJa: ["フランス", "ふらんす"],
                     answerEn: ["France", "france"],
                     answerMy: ["ပြင်သစ်"]),
            Question(imageName: "pyramid", category: .world,
                     answerJa: ["エジプト", "えじぷと"],
                     answerEn: ["Egypt", "egypt"],
                     answerMy: ["အီဂျစ်"]),
            Question(imageName: "statue_of_liberty", category: .world,
                     answerJa: ["アメリカ", "あめりか", "米国"],
                     answerEn: ["USA", "United States", "America", "usa", "america"],
                     answerMy: ["အမေရိကန်"]),
            Question(imageName: "collosseo", category: .world,
                     answerJa: ["イタリア", "いたりあ"],
                     answerEn: ["Italy", "italy"],
                     answerMy: ["အီတလီ"]),
            Question(imageName: "fuji_san", category: .world,
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
                    answerJa: ["イギリス", "いぎりす", "英国"],
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

            Question(imageName: "halloween_black_cat", category: .halloween,
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
