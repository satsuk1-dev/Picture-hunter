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
    let answerJa: [String]    // Japanese correct answers / 日本語正解リスト
    let answerEn: [String]    // English correct answers / 英語正解リスト
    let answerMy: [String]    // Myanmar correct answers / ミャンマー語正解リスト
    
    /// Get correct answers based on selected language
    func localizedAnswers(for language: Language) -> [String] {
        switch language {
        case .japanese: return answerJa
        case .english:  return answerEn
        case .myanmar:  return answerMy
        }
    }
}

// MARK: - Game Progress Management ViewModel / ゲーム進行管理 ViewModel
class GameModel: ObservableObject {
    @Published var activeQuestions: [Question] = [] // The 3 randomly selected questions
    @Published var currentIndex: Int = 0
    @Published var currentZoomScale: CGFloat = 5.0
    @Published var currentScore: Int = 1000
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isCorrectAnswer: Bool? = nil
    @Published var currentCategory: GameCategory = .school
    
    private var timer: Timer?
    private let minZoomScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.03
    
    // Master database of questions / 全問題のデータベース
    private var masterQuestionBank: [Question] = []
    
    init() {
        loadMasterQuestions()
    }
    
    /// Load all questions for all categories / 全モードの問題データ読み込み
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
            Question(imageName: "world_eiffel", category: .world,
                     answerJa: ["エッフェル塔", "エッフェルとう", "えっふぇるとう"],
                     answerEn: ["Eiffel Tower", "eiffel tower", "eiffeltower"],
                     answerMy: ["အီဖယ် တာဝါ"]),
            Question(imageName: "world_pyramid", category: .world,
                     answerJa: ["ピラミッド", "ぴらみっど"],
                     answerEn: ["pyramid", "Pyramid"],
                     answerMy: ["ပိရမစ်"]),
            Question(imageName: "world_statue_liberty", category: .world,
                     answerJa: ["自由の女神", "じゆうのめがみ"],
                     answerEn: ["Statue of Liberty", "statue of liberty"],
                     answerMy: ["လွတ်လပ်ရေးကျောက်တိုင်"]),
                     
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
    
    /// Prepare 3 random questions for the selected mode and start / 選択モードからランダムで3問選んで開始
    func setupAndStartGame(category: GameCategory) {
        self.currentCategory = category
        
        // Filter questions by selected category / モード別にフィルタリング
        let filtered = masterQuestionBank.filter { $0.category == category }
        
        // Pick 3 random questions / 3問をランダムにピックアップ
        self.activeQuestions = Array(filtered.shuffled().prefix(3))
        
        // Reset states
        self.currentIndex = 0
        self.currentScore = 1000
        self.currentZoomScale = 5.0
        self.isGameOver = false
        self.isCorrectAnswer = nil
        
        startGame()
    }
    
    /// Get the current active question
    var currentQuestion: Question? {
        guard currentIndex < activeQuestions.count else { return nil }
        return activeQuestions[currentIndex]
    }
    
    /// Start timer and zoom-out logic
    func startGame() {
        isPlaying = true
        isCorrectAnswer = nil
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            // Decrease zoom scale until 1.0
            if self.currentZoomScale > self.minZoomScale {
                self.currentZoomScale -= self.zoomStep
            }
            
            // Decrease score over time
            if self.currentScore > 0 {
                self.currentScore -= 5
            } else {
                self.currentScore = 0
                self.stopGame()
                self.isGameOver = true
            }
        }
    }
    
    /// Stop timer
    func stopGame() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    /// Check user input answer
    func checkAnswer(_ input: String, language: Language) -> Bool {
        guard let question = currentQuestion else { return false }
        
        let validAnswers = question.localizedAnswers(for: language)
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = validAnswers.contains { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == formattedInput
        }
        
        if isCorrect {
            isCorrectAnswer = true
            // Passage à la question suivante après un petit délai ou direct
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.nextQuestion()
            }
            return true
        } else {
            isCorrectAnswer = false
            currentScore = max(0, currentScore - 150)
            
            if currentScore == 0 {
                stopGame()
                isGameOver = true
            }
            return false
        }
    }
    
    /// Advance to next question or end game after 3 photos
    func nextQuestion() {
        if currentIndex + 1 < activeQuestions.count {
            currentIndex += 1
            currentZoomScale = 5.0
            isCorrectAnswer = nil
        } else {
            // 3/3 photos trouvées : Victoire !
            stopGame()
            isGameOver = true
        }
    }
}
