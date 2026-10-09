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
    
    /// Get ALL correct answers across ALL languages
    var allAnswers: [String] {
        return answerJa + answerEn + answerMy
    }
}

// MARK: - Game Progress Management ViewModel / ゲーム進行管理 ViewModel
class GameModel: ObservableObject {
    @Published var activeQuestions: [Question] = [] // 出題キュー（60秒間ループ）
    @Published var currentIndex: Int = 0
    @Published var currentZoomScale: CGFloat = 5.0
    
    @Published var imageScore: Int = 1000       // 現在の画像で獲得できるスコア
    @Published var totalScore: Int = 0          // 60秒間で獲得した合計スコア
    @Published var globalTimeRemaining: Int = 60 // 60秒タイムアタック用タイマー
    @Published var correctCount: Int = 0        // 正解した問題数
    
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isCorrectAnswer: Bool? = nil
    @Published var currentCategory: GameCategory = .school
    
    private var timer: Timer?
    private let minZoomScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.04 // 10秒でズームアウト完了（スピード感アップ）
    
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
                     answerMy: ["သရဲ"])
        ]
    }
    
    /// 60秒タイムアタックゲームの初期化と開始
    func setupAndStartGame(category: GameCategory) {
        stopGame()
        
        self.currentCategory = category
        let filtered = masterQuestionBank.filter { $0.category == category }
        // ランダムに並び替えてセット（問題数が足りなくなったらループ）
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
    
    /// 60秒の全体タイマーを開始
    private func startGlobalTimer() {
        isPlaying = true
        timer?.invalidate()
        
        var subTickCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            // 1. ズームアウトアニメーション
            if self.currentZoomScale > self.minZoomScale {
                self.currentZoomScale -= self.zoomStep
            }
            
            // 2. 問題単位の獲得スコア減点（早く答えるほど高得点）
            if self.imageScore > 200 {
                self.imageScore -= 10
            }
            
            // 3. 1秒カウントダウン (0.1秒 × 10回)
            subTickCount += 1
            if subTickCount >= 10 {
                subTickCount = 0
                if self.globalTimeRemaining > 1 {
                    self.globalTimeRemaining -= 1
                } else {
                    self.globalTimeRemaining = 0
                    self.finishGame() // 60秒経過でゲーム終了！
                }
            }
        }
    }
    
    /// 問題切り替え時の初期化
    private func startQuestionRound() {
        isCorrectAnswer = nil
        currentZoomScale = 5.0
        imageScore = 1000
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
    
    /// 解答チェック
    func checkAnswer(_ input: String) -> Bool {
        guard let question = currentQuestion, isPlaying else { return false }
        
        let validAnswers = question.allAnswers
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = validAnswers.contains { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == formattedInput
        }
        
        if isCorrect {
            isCorrectAnswer = true
            totalScore += imageScore
            correctCount += 1
            
            // 0.4秒後に次の問題へ
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                if self.isPlaying {
                    self.nextQuestion()
                }
            }
            return true
        } else {
            isCorrectAnswer = false
            imageScore = max(100, imageScore - 150) // お手つきペナルティ
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                if self.isCorrectAnswer == false {
                    self.isCorrectAnswer = nil
                }
            }
            return false
        }
    }
    
    /// 次の問題へ移動（無限ループ対応）
    func nextQuestion() {
        currentIndex += 1
        // リストを一周したら再度シャッフル
        if currentIndex >= activeQuestions.count {
            activeQuestions.shuffle()
            currentIndex = 0
        }
        startQuestionRound()
    }
    
    /// パス機能（分からない場合に次へ）
    func skipQuestion() {
        guard isPlaying else { return }
        nextQuestion()
    }
}
