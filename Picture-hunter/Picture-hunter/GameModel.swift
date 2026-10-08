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
    @Published var activeQuestions: [Question] = [] // Les 3 questions sélectionnées
    @Published var currentIndex: Int = 0
    @Published var currentZoomScale: CGFloat = 5.0
    
    @Published var imageScore: Int = 1000       // Score pour l'image en cours (Max 1000)
    @Published var totalScore: Int = 0          // Score total cumulé pour le classement
    @Published var timeRemaining: Int = 20      // Chrono individuel de 20s par image
    
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isCorrectAnswer: Bool? = nil
    @Published var currentCategory: GameCategory = .school
    
    private var timer: Timer?
    private let minZoomScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.02 // 20 secondes pour dézoomer de 5.0 à 1.0
    
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
                     
            // --- MODE WORLD (Pays / Countries) ---
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
    
    /// Initialise la partie (3 photos)
    func setupAndStartGame(category: GameCategory) {
        stopGame()
        
        self.currentCategory = category
        let filtered = masterQuestionBank.filter { $0.category == category }
        self.activeQuestions = Array(filtered.shuffled().prefix(3))
        
        self.currentIndex = 0
        self.totalScore = 0
        self.isGameOver = false
        
        startRound()
    }
    
    var currentQuestion: Question? {
        guard currentIndex < activeQuestions.count else { return nil }
        return activeQuestions[currentIndex]
    }
    
    /// Lance un round de 20 secondes pour l'image courante
    func startRound() {
        isPlaying = true
        isCorrectAnswer = nil
        currentZoomScale = 5.0
        imageScore = 1000
        timeRemaining = 20
        
        timer?.invalidate()
        
        var subTickCount = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            // 1. Dézoom fluide de 5.0 à 1.0
            if self.currentZoomScale > self.minZoomScale {
                self.currentZoomScale -= self.zoomStep
            }
            
            // 2. Diminution du score de l'image
            if self.imageScore > 0 {
                self.imageScore -= 5
            }
            
            // 3. Gestion du chrono d'une seconde (tous les 10 ticks de 0.1s)
            subTickCount += 1
            if subTickCount >= 10 {
                subTickCount = 0
                if self.timeRemaining > 1 {
                    self.timeRemaining -= 1
                } else {
                    self.timeRemaining = 0
                    // Temps écoulé pour cette image -> On passe à la suivante !
                    self.nextQuestion()
                }
            }
        }
    }
    
    func stopGame() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    /// Vérifie la réponse (Toutes les langues sont acceptées)
    func checkAnswer(_ input: String) -> Bool {
        guard let question = currentQuestion, isPlaying else { return false }
        
        let validAnswers = question.allAnswers // 🌐 Accepte FR, EN, JA, MY !
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        let isCorrect = validAnswers.contains { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == formattedInput
        }
        
        if isCorrect {
            isCorrectAnswer = true
            totalScore += imageScore // Ajoute le score de cette image au Total
            
            // Passe à l'image suivante après 0.8 seconde
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.nextQuestion()
            }
            return true
        } else {
            isCorrectAnswer = false
            imageScore = max(0, imageScore - 150) // Pénalité sur l'image en cours
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                if self.isCorrectAnswer == false {
                    self.isCorrectAnswer = nil
                }
            }
            return false
        }
    }
    
    /// Avance à l'image suivante ou termine la partie au bout de 3 images
    func nextQuestion() {
        timer?.invalidate()
        
        if currentIndex + 1 < activeQuestions.count {
            currentIndex += 1
            startRound() // Relance les 20s et le zoom pour l'image 2 ou 3
        } else {
            // Fin des 3 images -> Victoire / Sauvegarde du score !
            stopGame()
            isGameOver = true
        }
    }
}
