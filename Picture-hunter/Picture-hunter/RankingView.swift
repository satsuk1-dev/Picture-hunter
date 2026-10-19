import SwiftUI

struct RankingView: View {

    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {

            Text("🏆 RANKING")
                .font(.largeTitle)
                .bold()

            Text("ランキング")
                .font(.title2)
                .foregroundStyle(.secondary)

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
    }
}

#Preview {
    RankingView()
        .environmentObject(ScoreManager())
}
