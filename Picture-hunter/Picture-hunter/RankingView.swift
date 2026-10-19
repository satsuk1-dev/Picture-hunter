import SwiftUI

struct RankingView: View {
    
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) private var dismiss
    var initialCategory: String = "世界"
    @State private var selectedCategory = "世界"
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.6), .purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                
                Text("🏆 RANKING")
                    .font(.largeTitle)
                    .bold()
                
                //                Text("ランキング")
                //                    .font(.title2)
                //                    .foregroundStyle(.secondary)
                
                // Category Button 3 ခု
                HStack(spacing: 10) {
                    ForEach(["世界", "学校", "ハロウィン"], id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.subheadline)
                                .bold()
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    selectedCategory == category
                                    ? Color.blue
                                    : Color.white.opacity(0.2)
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                        }
                    }
                }
                
                Text("\(selectedCategory) ランキング")
                    .font(.headline)
                    .bold()
                
                Divider()
                
                HStack {
                    Text("順位")
                    Spacer()
                    Text("PLAYER")
                    Spacer()
                    Text("SCORE")
                }
                .font(.headline)
                .foregroundStyle(.secondary)
                
                if scoreManager.highScores.isEmpty {
                    Spacer()
                    
                    Text("まだランキングがありません")
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                } else {
                    ForEach(
                        Array(scoreManager.highScores.enumerated()),
                        id: \.element.id
                    ) { index, item in
                        
                        HStack(spacing: 15) {
                            Text("\(index + 1)位")
                                .font(.title3)
                                .bold()
                                .frame(width: 55)
                            
                            Text(item.name)
                                .font(.headline)
                            
                            Spacer()
                            
                            Text("\(item.score)")
                                .font(.title3)
                                .bold()
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    Spacer()
                }
                
                Button {
                    dismiss()
                } label: {
                    Label("ホームに戻る", systemImage: "house")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(20)
            .onAppear {
                selectedCategory = initialCategory
            }
        }
    }
}
#Preview {
    RankingView()
        .environmentObject(ScoreManager())
}
