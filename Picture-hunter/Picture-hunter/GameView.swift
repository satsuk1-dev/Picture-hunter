import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) var dismiss
    
    let category: GameCategory
    var onExit: (() -> Void)? = nil
    @StateObject private var gameModel = GameModel()
    @State private var inputAnswer: String = ""
    @State private var playerName: String = ""
    @State private var showNameInputDialog = false
    @State private var showTotalScoreView = false
    
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
            .onTapGesture {
                isInputFocused = false   // 空いている所をタップするとキーボードが閉じる
            }
            
            VStack(spacing: 16) {
                
                // 1. Header — Back + Found images + 60s timer
                HStack(spacing: 10) {
                    // 戻るボタン
                    Button(action: exitGame) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)
                    
                    // 正解枚数
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
                    
                    // 残り時間
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
                
                // Question Header
                Text(langManager.text(for: questionPromptKey))
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                
                // Photo Area(画面の幅に合わせて正方形。入力中は小さくなる)
                Color.clear
                    .aspectRatio(1, contentMode: .fit)
                    .overlay {
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
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .allowsHitTesting(false)   // 戻るボタンが1回で反応するために必要
                    .frame(maxWidth: isInputFocused ? 260 : 340)
                    .padding(.horizontal, 20)
                    .animation(.easeInOut(duration: 0.25), value: isInputFocused)
                
                // Skip & Pause(写真の下)
                HStack(spacing: 20) {
                    Button(action: {
                        gameModel.skipQuestion()
                        inputAnswer = ""
                    }) {
                        Text("パス (Skip)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(12)
                    }
                    
                    Button(action: {
                        if gameModel.isPlaying {
                            gameModel.stopGame()
                        } else {
                            gameModel.setupAndStartGame(category: category)
                        }
                    }) {
                        Text(gameModel.isPlaying ? langManager.text(for: "pause") : langManager.text(for: "resume"))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }
                
                // Feedback
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
                
//                // デバッグ用:答えを表示(リリース版には出ません)
//                #if DEBUG
//                if let question = gameModel.currentQuestion {
//                    Text("答え: " + question.allAnswers.joined(separator: " / "))
//                        .font(.caption)
//                        .foregroundColor(.yellow)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal, 16)
//                }
//                #endif
                
                Spacer()
                
                // Input
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
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            inputAnswer = ""
            gameModel.setupAndStartGame(category: category)
        }
        .onChange(of: gameModel.currentIndex) { newValue in
            inputAnswer = ""
        }
        .onChange(of: gameModel.isGameOver) { newValue in
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
                
                scoreManager.addScore(name: nameToSave, score: gameModel.correctCount, category: category.rawValue)
                playerName = ""
                showTotalScoreView = true
            }
        } message: {
            Text("60秒で \(gameModel.correctCount) 枚の画像を当てました！")
        }
        .sheet(isPresented: $showTotalScoreView) {
            TotalscoreView(
                score: gameModel.correctCount,
                correctAnswers: gameModel.correctCount,
                totalQuestions: gameModel.activeQuestions.count,
                bestScore: scoreManager.scores(for: category.rawValue).first?.score ?? gameModel.correctCount,
                onRestart: {
                    gameModel.setupAndStartGame(category: category)
                },
                onHome: {
                    dismiss()
                }
            )
        }
    }
    
    private func submitAnswer() {
        guard !inputAnswer.isEmpty else { return }
        let _ = gameModel.checkAnswer(inputAnswer)
        inputAnswer = ""
    }
    
    private func exitGame() {
        isInputFocused = false
        gameModel.stopGame()
        if let onExit {
            onExit()
        } else {
            dismiss()
        }
    }
}

#Preview {
    GameView(category: .school)
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
