import SwiftUI

struct RankingView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    @Environment(\.dismiss) private var dismiss
    
    var initialCategory: String = "世界"
    @State private var selectedCategory = "世界"
    @State private var showResetAlert = false
    
    // Correspondance entre la clé de langue et la catégorie de stockage
    private let categoryKeys: [(key: String, storageValue: String)] = [
        ("mode_world", "世界"),
        ("mode_school", "学校"),
        ("mode_halloween", "ハロウィン")
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.blue.opacity(0.6), .purple.opacity(0.8)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                headerView
                categoryButtonsView

                Text("\(localizedCategoryName(for: selectedCategory)) \(langManager.text(for: "ranking"))")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.white)

                Divider()
                    .background(Color.white.opacity(0.5))

                tableHeaderView
                rankingListView

                Spacer()

                homeButton
            }
            .padding(20)
            .onAppear {
                selectedCategory = initialCategory
            }
        }
        .alert(langManager.text(for: "delete_ranking_title"), isPresented: $showResetAlert) {
            Button("\(langManager.text(for: "delete_this_category")) (\(localizedCategoryName(for: selectedCategory)))", role: .destructive) {
                scoreManager.resetScores(for: selectedCategory)
            }
            Button(langManager.text(for: "delete_all_rankings"), role: .destructive) {
                scoreManager.resetAllScores()
            }
            Button(langManager.text(for: "cancel"), role: .cancel) {}
        } message: {
            Text(langManager.text(for: "delete_ranking_message"))
        }
    }
    
    // MARK: - Subviews & Helpers

    private var headerView: some View {
        HStack {
            Spacer()
            
            Text("\(langManager.text(for: "ranking"))")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            Button {
                showResetAlert = true
            } label: {
                Image(systemName: "trash.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(10)
                    .background(Color.red.opacity(0.3))
                    .clipShape(Circle())
            }
        }
    }

    private var categoryButtonsView: some View {
        HStack(spacing: 10) {
            ForEach(categoryKeys, id: \.storageValue) { item in
                Button {
                    withAnimation {
                        selectedCategory = item.storageValue
                    }
                } label: {
                    Text(langManager.text(for: item.key))
                        .font(.subheadline)
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            selectedCategory == item.storageValue
                            ? Color.blue
                            : Color.white.opacity(0.2)
                        )
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
        }
    }

    private var tableHeaderView: some View {
        HStack {
            Text("順位")
                .frame(width: 50, alignment: .leading)
            Spacer()
            Text("PLAYER")
            Spacer()
            Text("SCORE")
                .frame(width: 60, alignment: .trailing)
        }
        .font(.headline)
        .foregroundColor(.white.opacity(0.8))
        .padding(.horizontal)
    }

    @ViewBuilder
        private var rankingListView: some View {
            let filteredScores = scoreManager.highScores.filter { item in
                let cat = item.category.lowercased()
                switch selectedCategory {
                case "世界":
                    return cat == "世界" || cat == "world"
                case "学校":
                    return cat == "学校" || cat == "school"
                case "ハロウィン":
                    return cat == "ハロウィン" || cat == "halloween"
                default:
                    return cat == selectedCategory.lowercased()
                }
            }.sorted { $0.score > $1.score }

            if filteredScores.isEmpty {
                Spacer()
                Text(langManager.text(for: "no_score"))
                    .foregroundColor(.white.opacity(0.7))
                    .font(.body)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(Array(filteredScores.prefix(10).enumerated()), id: \.element.id) { index, item in
                            HStack {
                                Text("\(index + 1)")
                                    .font(.title3)
                                    .bold()
                                    .frame(width: 50, alignment: .leading)

                                Text(item.name)
                                    .font(.headline)
                                    .lineLimit(1)

                                Spacer()

                                Text("\(item.score)")
                                    .font(.title3)
                                    .bold()
                                    .frame(width: 60, alignment: .trailing)
                            }
                            .padding()
                            .background(Color.white.opacity(0.15))
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    }
                }
            }
        }
    private var homeButton: some View {
        Button {
            dismiss()
        } label: {
            Label(langManager.text(for: "close"), systemImage: "house.fill")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .buttonStyle(.borderedProminent)
        .tint(.white.opacity(0.2))
        .foregroundColor(.white)
    }

    private func localizedCategoryName(for storageValue: String) -> String {
        switch storageValue {
        case "世界":
            return langManager.text(for: "mode_world")
        case "学校":
            return langManager.text(for: "mode_school")
        case "ハロウィン":
            return langManager.text(for: "mode_halloween")
        default:
            return storageValue
        }
    }
}

#Preview {
    RankingView()
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
