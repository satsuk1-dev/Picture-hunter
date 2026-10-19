import SwiftUI

struct TotalscoreView: View {
    var score: Int
    var correctAnswers: Int
    var totalQuestions: Int
    var bestScore: Int
    
    var onRestart: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.25),
                    Color(red: 0.05, green: 0.05, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Header Titles
                VStack(spacing: 6) {
                    Text("TOTAL RESULT")
                        .font(.system(.subheadline, design: .rounded))
                        .fontWeight(.black)
                        .foregroundStyle(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 6)
                        .background(Color.blue.opacity(0.15))
                        .clipShape(Capsule())
                    
                    Text("PICTURE HUNTER")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.heavy)
                        .foregroundColor(.white.opacity(0.8))
                }
                .padding(.top, 10)
                
                // Score Box (Glassmorphism Container)
                VStack(spacing: 10) {
                    Text("TOTAL SCORE")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.gray)
                    
                    Text("\(score)")
                        .font(.system(size: 85, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: score >= 5 ? [.green, .mint] : [.orange, .red],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    Text("POINTS")
                        .font(.system(.footnote, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.06))
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                
                Divider()
                    .background(Color.white.opacity(0.2))
                    .padding(.horizontal, 20)
                HStack(spacing: 30) {
                    VStack(spacing: 6) {
                        Text("正解数")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)

                        Text("\(correctAnswers)/\(totalQuestions)")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(16)

                    VStack(spacing: 6) {
                        Text("BEST SCORE")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.gray)

                        Text("\(bestScore)")
                            .font(.system(.title2, design: .rounded))
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white.opacity(0.04))
                    .cornerRadius(16)
                }
                
                Text(resultMessage)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundStyle(score >= 5 ? .green : .orange)
                
                Spacer()
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button {
                            dismiss()
                        } label: {
                            Label("ホーム", systemImage: "house.fill")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white.opacity(0.1))
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }

                        Button {
                            dismiss()
                            onRestart()
                        } label: {
                            Label("もう一度", systemImage: "arrow.clockwise")
                                .font(.system(.body, design: .rounded))
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .foregroundColor(.white)
                                .cornerRadius(16)
                        }
                    }
                }
            }
            .padding(24)
        }
    }
    
    var resultMessage: String {
        if score >= 15 {
            return "Excellent! 🎉"
        } else if score >= 5 {
            return "Good Job! 👏"
        } else {
            return "Try Again! 💪"
        }
    }
}

#Preview {
    TotalscoreView(
        score: 8,
        correctAnswers: 8,
        totalQuestions: 15,
        bestScore: 12,
        onRestart: {}
    )
}
