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
                
                // MARK: - 1. Header (Score Total, Correct Count & Global Timer 60s)
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
                    
                    Text("正解数: \(gameModel.correctCount)")
                        .font(.headline)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)
                        Text("\(gameModel.globalTimeRemaining)s")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(gameModel.globalTimeRemaining <= 10 ? .red : .orange)
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
                .frame(width: 300, height: 300)
                .cornerRadius(24)
                .clipped()
                
                // Feedback (Correct / Incorrect)
                if let isCorrect = gameModel.isCorrectAnswer {
                    Text(isCorrect ? langManager.text(for: "correct") : langManager.text(for: "incorrect"))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(isCorrect ? .green : .red)
                        .transition(.scale)
                } else {
                    // Espace réservé pour éviter les sauts de mise en page
                    Text("")
                        .font(.title2)
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
                    
                    // Controls (Skip & Pause)
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
            inputAnswer = ""
        } else {
            inputAnswer = ""
        }
    }
}
