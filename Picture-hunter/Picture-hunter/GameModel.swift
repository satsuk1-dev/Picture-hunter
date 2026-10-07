import Foundation
import SwiftUI
import Combine

// MARK: - Quiz Question Data Model / クイズ問題データモデル
struct Question: Identifiable {
    let id = UUID()
    let imageName: String      // Image asset name / Assets内の画像名
    let answerJa: [String]    // Japanese correct answers list / 日本語の正解リスト
    let answerEn: [String]    // English correct answers list / 英語の正解リスト
    let answerMy: [String]    // Myanmar correct answers list / ミャンマー語の正解リスト
    
    /// Get the list of correct answers based on the selected language.
    /// 選択されている言語に応じた正解リストを取得
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
    @Published var questions: [Question] = []
    @Published var currentIndex: Int = 0
    @Published var currentZoomScale: CGFloat = 5.0
    @Published var currentScore: Int = 1000
    @Published var isPlaying: Bool = false
    @Published var isGameOver: Bool = false
    @Published var isCorrectAnswer: Bool? = nil
    
    private var timer: Timer?
    private let minZoomScale: CGFloat = 1.0
    private let zoomStep: CGFloat = 0.03
    
    init() {
        loadSampleQuestions()
    }
    
    /// Load sample quiz data / サンプル問題データの読み込み
    func loadSampleQuestions() {
        self.questions = [
            Question(
                imageName: "sample_photo1",
                answerJa: ["東京タワー", "とうきょうたわー"],
                answerEn: ["Tokyo Tower", "tokyo tower", "Tokyo tower", "tokyotower"],
                answerMy: ["ဒဂုံတာဝါ"]
            ),
            Question(
                imageName: "sample_photo2",
                answerJa: ["富士山", "ふじさん"],
                answerEn: ["Mt. Fuji", "mt. fuji", "mt fuji", "fuji", "fujisan"],
                answerMy: ["ဖူဂျီတောင်"]
            )
        ]
    }
    
    /// Get the current active question / 現在の問題を取得
    var currentQuestion: Question? {
        guard currentIndex < questions.count else { return nil }
        return questions[currentIndex]
    }
    
    /// Start the game timer and zoom-out logic / ゲームタイマーとズームアウト処理を開始
    func startGame() {
        isPlaying = true
        isCorrectAnswer = nil
        timer?.invalidate()
        
        // Execute every 0.1 seconds / 0.1秒ごとに処理を実行
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, self.isPlaying else { return }
            
            // 1. Decrease zoom scale until reaching minimum (1.0) / ズームの減少処理（最小値 1.0 まで）
            if self.currentZoomScale > self.minZoomScale {
                self.currentZoomScale -= self.zoomStep
            }
            
            // 2. Decrease score over time until reaching 0 / スコアの減少処理（0 になるまで減らし続ける）
            if self.currentScore > 0 {
                self.currentScore -= 5
            } else {
                // Game Over when score reaches 0 / スコアが 0 になったらゲームオーバー
                self.currentScore = 0
                self.stopGame()
                self.isGameOver = true
            }
        }
    }
    
    /// Stop the timer and pause the game state / タイマーを停止しゲームを中断
    func stopGame() {
        isPlaying = false
        timer?.invalidate()
        timer = nil
    }
    
    /// Check if user input matches any acceptable correct answer / ユーザー入力が正解リストのいずれかに一致するかチェック
    func checkAnswer(_ input: String, language: Language) -> Bool {
        guard let question = currentQuestion else { return false }
        
        let validAnswers = question.localizedAnswers(for: language)
        let formattedInput = input.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        
        // Check if input matches any answer in the list (case insensitive) / 大文字小文字を無視して一致するか確認
        let isCorrect = validAnswers.contains { answer in
            answer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == formattedInput
        }
        
        if isCorrect {
            isCorrectAnswer = true
            return true
        } else {
            isCorrectAnswer = false
            currentScore = max(0, currentScore - 150)
            
            // Trigger Game Over if score hits 0 due to wrong answer / 不正解でスコアが 0 になった場合もゲームオーバー
            if currentScore == 0 {
                stopGame()
                isGameOver = true
            }
            return false
        }
    }
    
    /// Advance to the next question or trigger game over / 次の問題に進む、またはゲームオーバー処理
    func nextQuestion() {
        if currentIndex + 1 < questions.count {
            currentIndex += 1
            currentZoomScale = 5.0
            isCorrectAnswer = nil
        } else {
            stopGame()
            isGameOver = true
        }
    }
}
