import SwiftUI

struct RankingView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color.purple.opacity(0.9), Color.blue.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text(langManager.text(for: "ranking"))
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                if scoreManager.highScores.isEmpty {
                    Spacer()
                    Text(langManager.text(for: "no_scores"))
                        .foregroundColor(.white.opacity(0.7))
                        .font(.headline)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(Array(scoreManager.highScores.enumerated()), id: \.element.id) { index, item in
                                HStack(spacing: 15) {
                                    ZStack {
                                        Circle()
                                            .fill(rankColor(for: index + 1))
                                            .frame(width: 40, height: 40)
                                        
                                        Text("\(index + 1)")
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Text(item.name)
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Spacer()
                                    
                                    Text("\(item.score) \(langManager.text(for: "pts"))")
                                        .font(.system(.body, design: .monospaced))
                                        .fontWeight(.bold)
                                        .foregroundColor(.yellow)
                                }
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    private func rankColor(for rank: Int) -> Color {
        switch rank {
        case 1: return Color.yellow
        case 2: return Color.gray
        case 3: return Color.brown
        default: return Color.white.opacity(0.3)
        }
    }
}
