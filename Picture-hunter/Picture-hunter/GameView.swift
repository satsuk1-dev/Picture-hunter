import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) var dismiss
    
    let category: GameCategory
    @StateObject private var gameModel = GameModel()
    
    @State private var inputAnswer: String = ""
    @State private var playerName: String = ""
    @State private var showNameInputDialog = false
    
    // 1. Variable d'état pour ouvrir TotalscoreView
    @State private var showTotalScoreView = false
    
    // Focus state pour détecter quand le clavier est ouvert
    @FocusState private var isInputFocused: Bool
    
    private var questionPromptKey: String {
        switch category {
        case .school:
            return "question_school"
        case .world:
            return "question_world"
        case .halloween:
            return "question_halloween"
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                
                // 1. Header — Found images + 60s timer
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "photo.stack.fill")
                            .foregroundColor(.green)
                            .font(.title3)
                        
                        Text("\(gameModel.correctCount) 枚")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                    
                    Spacer()
                    
                    // 60s countdown / 60秒カウントダウン
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)
                        
                        Text("\(gameModel.globalTimeRemaining)s")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // Mode Question Header / モード別質問テキスト
                Text(langManager.text(for: questionPromptKey))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Photo Area — Dynamic zoom-out / 写真エリア — 動的ズームアウト
                ZStack {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color(white: 0.2))
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 5)
                    
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                    
                    if let question = gameModel.currentQuestion {
                        Image(question.imageName)
                            .resizable()
                            .scaledToFill()
                            .scaleEffect(gameModel.currentZoomScale)
                            .animation(.linear(duration: 0.1), value: gameModel.currentZoomScale)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 80))
                            .foregroundColor(.gray)
                    }
                }
                .frame(width: 340, height: 340)
                .cornerRadius(24)
                .clipped()
                
                // Feedback (Correct / Incorrect) / フィードバック（正解 / 不正解）
                if let isCorrect = gameModel.isCorrectAnswer {
                    Text(isCorrect ? langManager.text(for: "correct") : langManager.text(for: "incorrect"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isCorrect ? .green : .red)
                        .transition(.scale)
                } else {
                    Text("")
                        .font(.title2)
                }
                
                Spacer()
                
                // Input & Controls / 入力と操作
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        TextField(langManager.text(for: "type_answer"), text: $inputAnswer)
                            .focused($isInputFocused)
                            .padding()
                            .background(Color(white: 0.2))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                            )
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                            .onSubmit {
                                submitAnswer()
                            }
                        
                        Button(action: {
                            submitAnswer()
                        }) {
                            Image(systemName: "paperplane.fill")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding()
                                .background(inputAnswer.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(inputAnswer.isEmpty)
                    }
                    
                    // Controls — Skip & Pause / 操作 — スキップと一時停止
                    HStack(spacing: 20) {
                        Button(action: {
                            gameModel.skipQuestion()
                            inputAnswer = ""
                        }) {
                            Text("パス (Skip)")
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            if gameModel.isPlaying {
                                gameModel.stopGame()
                            } else {
                                gameModel.setupAndStartGame(category: category)
                            }
                        }) {
                            Text(gameModel.isPlaying ? langManager.text(for: "pause") : langManager.text(for: "resume"))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        // Toolbar au-dessus du clavier
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Text("入力中:")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Text(inputAnswer.isEmpty ? "..." : inputAnswer)
                        .font(.body)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("OK") {
                        submitAnswer()
                        isInputFocused = false
                    }
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                }
                .padding(.horizontal, 8)
            }
        }
        .onAppear {
            inputAnswer = ""
            gameModel.setupAndStartGame(category: category)
        }
        .onChange(of: gameModel.currentIndex) { oldValue, newValue in
            inputAnswer = ""
        }
        .onChange(of: gameModel.isGameOver) { oldValue, newValue in
            if newValue {
                showNameInputDialog = true
            }
        }
        .alert(langManager.text(for: "enter_name_title"), isPresented: $showNameInputDialog) {
            TextField(langManager.text(for: "name_placeholder"), text: $playerName)
            Button(langManager.text(for: "save_button")) {
                let nameToSave = playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "Player"
                    : playerName
                
                scoreManager.addScore(name: nameToSave, score: gameModel.correctCount)
                playerName = ""
                
                // 2. Afficher la feuille TotalscoreView une fois le nom sauvegardé
                showTotalScoreView = true
            }
        } message: {
            Text("60秒で \(gameModel.correctCount) 枚の画像を当てました！")
        }
        // 3. Présentation de la modal TotalscoreView avec les vraies données
        .sheet(isPresented: $showTotalScoreView) {
            TotalscoreView(
                score: gameModel.correctCount,
                correctAnswers: gameModel.correctCount,
                totalQuestions: gameModel.activeQuestions.count,
                bestScore: scoreManager.highScores.first?.score ?? gameModel.correctCount,
                onRestart: {
                    gameModel.setupAndStartGame(category: category)
                }
            )
        }
    }
    
    private func submitAnswer() {
        guard !inputAnswer.isEmpty else { return }
        let _ = gameModel.checkAnswer(inputAnswer)
        inputAnswer = ""
    }
}
