import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) var dismiss
    @Environment(\.verticalSizeClass) private var verticalSizeClass
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
    
    private func computedImageMaxWidth() -> CGFloat {
        let isCompactVert = verticalSizeClass == .compact
        
        let screenHeight = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.screen.bounds.height ?? 0

        if isInputFocused {
            if screenHeight <= 667 {
                return 280
            }
            return isCompactVert ? 240 : 300
        } else {
            if screenHeight <= 667 {
                return 330
            }
            return isCompactVert ? 300 : 360
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
                withAnimation(.easeInOut(duration: 0.3)) {
                    isInputFocused = false
                }
            }

            VStack(spacing: isInputFocused ? 2 : 14) {

                // 1. Header
                HStack(spacing: 10) {
                    Button(action: exitGame) {
                        Image(systemName: "chevron.left")
                            .font(.title3.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.1))
                            .clipShape(Circle())
                            .contentShape(Circle())
                    }
                    .buttonStyle(.plain)

                    HStack(spacing: 8) {
                        Image(systemName: "photo.stack.fill")
                            .foregroundColor(.green)
                            .font(.subheadline)

                        Text("\(gameModel.correctCount) 枚")
                            .font(.system(.headline, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)

                    Spacer()

                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)

                        Text("\(gameModel.globalTimeRemaining)s")
                            .font(.system(.headline, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 6)

                Spacer(minLength: isInputFocused ? 0 : 12)

                // Question Header
                Text(langManager.text(for: questionPromptKey))
                    .font(.system(isInputFocused ? .subheadline : .title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)

                // Photo Area
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
                                    .font(.system(size: 70))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .allowsHitTesting(false)
                    .frame(maxWidth: computedImageMaxWidth())
                    .padding(.horizontal, 16)

                // Skip & Pause
                HStack(spacing: 16) {
                    Button(action: {
                        gameModel.skipQuestion()
                        inputAnswer = ""
                    }) {
                        Text("パス (Skip)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
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
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 10)
                            .padding(.horizontal, 18)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                    }
                }

                // Feedback
                if let isCorrect = gameModel.isCorrectAnswer {
                    Text(isCorrect ? langManager.text(for: "correct") : langManager.text(for: "incorrect"))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(isCorrect ? .green : .red)
                        .transition(.scale)
                } else {
                    Text("")
                        .font(.headline)
                }

                Spacer(minLength: isInputFocused ? 0 : 12)

                // Input Area
                HStack(spacing: 10) {
                    TextField(langManager.text(for: "type_answer"), text: $inputAnswer)
                        .focused($isInputFocused)
                        .padding(12)
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
                            .font(.body)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(inputAnswer.isEmpty ? Color.gray : Color.blue)
                            .cornerRadius(12)
                    }
                    .disabled(inputAnswer.isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
            .animation(.easeInOut(duration: 0.3), value: isInputFocused)
        }
        .toolbar(.hidden, for: .navigationBar)
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
        withAnimation(.easeInOut(duration: 0.3)) {
            isInputFocused = false
        }
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
