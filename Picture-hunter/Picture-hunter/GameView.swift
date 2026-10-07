import SwiftUI
import Combine

struct GameView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var gameModel = GameModel()
    
    @State private var inputAnswer: String = ""
    @State private var timeRemaining: Int = 30
    @State private var isGameRunning: Bool = true // Controls the timer / タイマーを制御
    @State private var playerName: String = ""
    @State private var showNameInputDialog = false
    
    let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.black, Color(white: 0.15)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                // MARK: - 1. Header (Score & Timer) / ヘッダー (スコア & タイマー)
                HStack {
                    HStack(spacing: 6) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(langManager.text(for: "score")): \(gameModel.currentScore)")
                            .font(.system(.title3, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 6) {
                        Image(systemName: "clock.fill")
                            .foregroundColor(.orange)
                        Text("\(timeRemaining)s")
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                Spacer()
                
                // MARK: - 2. Center Area (Zoom Photo Square) / 中央エリア (ズーム写真スクエア)
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
                
                // Feedback / フィードバック表示
                if let isCorrect = gameModel.isCorrectAnswer {
                    Text(isCorrect ? langManager.text(for: "correct") : langManager.text(for: "incorrect"))
                        .font(.headline)
                        .foregroundColor(isCorrect ? .green : .red)
                        .transition(.scale)
                }
                
                Spacer()
                
                // MARK: - 3. Bottom Area (Input Line) / 下部エリア (入力ライン)
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
                    
                    // Pause / Resume Button / 一時停止・再開ボタン
                    Button(action: {
                        isGameRunning.toggle()
                        if isGameRunning {
                            gameModel.startGame()
                        } else {
                            gameModel.stopGame()
                        }
                    }) {
                        Text(isGameRunning ? langManager.text(for: "pause") : langManager.text(for: "resume"))
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
            timeRemaining = 30
            isGameRunning = true
            gameModel.startGame()
        }
        .onReceive(timer) { _ in
            guard isGameRunning else { return }
            
            if timeRemaining > 1 {
                timeRemaining -= 1
            } else {
                timeRemaining = 0
                isGameRunning = false
                gameModel.stopGame()
                showNameInputDialog = true // Displays the alert as soon as time reaches 0 / 時間が0になったらアラートを表示
            }
        }
        .alert(langManager.text(for: "enter_name_title"), isPresented: $showNameInputDialog) {
            TextField(langManager.text(for: "name_placeholder"), text: $playerName)
            Button(langManager.text(for: "save_button")) {
                let nameToSave = playerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                    ? "Player"
                    : playerName
                
                scoreManager.addScore(name: nameToSave, score: gameModel.currentScore)
                playerName = ""
                dismiss()
            }
        } message: {
            Text(langManager.text(for: "enter_name_message"))
        }
    }
    
    private func submitAnswer() {
        guard !inputAnswer.isEmpty else { return }
        
        let isCorrect = gameModel.checkAnswer(inputAnswer, language: langManager.selectedLanguage)
        
        if isCorrect {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                inputAnswer = ""
                gameModel.nextQuestion()
            }
        } else {
            inputAnswer = ""
        }
    }
}

#Preview {
    GameView()
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
