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
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // MARK: - 1. Header (Score Total, Compteur 1/3 & Timer 20s)
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(langManager.text(for: "score")): \(gameModel.totalScore)")
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("\(gameModel.currentIndex + 1)/\(gameModel.activeQuestions.count)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("\(gameModel.timeRemaining)s")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - 2. Photo Area (Dézoom dynamique)
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
                .frame(width: 360, height: 360)
                .cornerRadius(24)
                .clipped()
                
                // Feedback (Correct / Incorrect)
                if let isCorrect = gameModel.isCorrectAnswer {
                    Text(isCorrect ? langManager.text(for: "correct") : langManager.text(for: "incorrect"))
                        .font(.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                        .transition(.scale)
                }
                
                Spacer()
                
                // MARK: - 3. Input Line & Controls
                VStack(spacing: 12) {
                    HStack(spacing: 10) {
                        TextField(langManager.text(for: "type_answer"), text: $inputAnswer)
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
                    
                    // Pause / Reprendre
                    Button(action: {
                        if gameModel.isPlaying {
                            gameModel.stopGame()
                        } else {
                            gameModel.startRound()
                        }
                    }) {
                        Text(gameModel.isPlaying ? langManager.text(for: "pause") : langManager.text(for: "resume"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.vertical, 8)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
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
                
                scoreManager.addScore(name: nameToSave, score: gameModel.totalScore)
                playerName = ""
                dismiss()
            }
        } message: {
            Text(langManager.text(for: "enter_name_message"))
        }
    }
    
    private func submitAnswer() {
        guard !inputAnswer.isEmpty else { return }
        let isCorrect = gameModel.checkAnswer(inputAnswer)
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                inputAnswer = ""
            }
        } else {
            inputAnswer = ""
        }
    }
}

#Preview {
    GameView(category: .school)
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
