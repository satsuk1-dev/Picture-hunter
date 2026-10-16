import SwiftUI

struct ContentView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    
    @Binding var isFinishedSplash: Bool
    
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var selectedCategory: GameCategory = .school
    
    @State private var showCategoryPicker = false
    @State private var showGameScreen = false
    @State private var showRankingScreen = false
    @State private var showSettingsScreen = false
    
    // Animation state
    @State private var isAnimatingBg = false
    @State private var appearAnimation = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                //  Dynamic modern gradient background / 動的でモダンなグラデーション背景
                LinearGradient(
                    colors: [
                        Color(red: 0.1, green: 0.05, blue: 0.25),
                        Color(red: 0.05, green: 0.15, blue: 0.35)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                //  Background glow effects (Glow Orbs) / 背景のグロー効果（グローオーブ）
                ZStack {
                    Circle()
                        .fill(Color.purple.opacity(0.4))
                        .frame(width: 280, height: 280)
                        .blur(radius: 80)
                        .offset(x: isAnimatingBg ? -100 : 100, y: isAnimatingBg ? -150 : -80)
                    
                    Circle()
                        .fill(Color.blue.opacity(0.4))
                        .frame(width: 300, height: 300)
                        .blur(radius: 90)
                        .offset(x: isAnimatingBg ? 120 : -80, y: isAnimatingBg ? 180 : 100)
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 7.0).repeatForever(autoreverses: true)) {
                        isAnimatingBg.toggle()
                    }
                }
                
                VStack(spacing: 0) {
                    // 🏠 Header (Home Button) / ヘッダー（ホームボタン）
                    HStack {
                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                isFinishedSplash = false
                            }
                        }) {
                            Image(systemName: "house.fill")
                                .font(.title3.weight(.semibold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(.white.opacity(0.15), in: Circle())
                                .overlay(
                                    Circle().stroke(Color.white.opacity(0.25), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        Spacer()
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 12)
                    
                    Spacer()
                    
                    // 📸 Logo & Main title / ロゴとメインタイトル
                    VStack(spacing: 16) {
                        
                        VStack(spacing: 8) {
                            Image("Picture-hunterTitle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 280)
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            
                            Text(langManager.text(for: "subtitle"))
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(.white.opacity(0.12), in: Capsule())
                                .overlay(
                                    Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .offset(y: appearAnimation ? 0 : 20)
                        .opacity(appearAnimation ? 1.0 : 0)
                    }
                    
                    Spacer()
                    
                    // 🎮 Main menu / メインメニュー
                    VStack(spacing: 16) {
                        // Play button / 再生ボタン
                        Button(action: { showCategoryPicker = true }) {
                            HStack(spacing: 12) {
                                Image(systemName: "play.fill")
                                    .font(.title2)
                                Text(langManager.text(for: "start"))
                                    .font(.system(size: 22, weight: .black, design: .rounded))
                            }
                            .foregroundColor(Color(red: 0.15, green: 0.05, blue: 0.3))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(colors: [.white, Color(white: 0.92)], startPoint: .top, endPoint: .bottom)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                            .shadow(color: .purple.opacity(0.35), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Ranking button / ランキングボタン
                        Button(action: { showRankingScreen = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "trophy.fill")
                                    .font(.title3)
                                    .foregroundColor(.yellow)
                                Text(langManager.text(for: "ranking"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                        
                        // Settings button / 設定ボタン
                        Button(action: { showSettingsScreen = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "gearshape.fill")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(langManager.text(for: "settings"))
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal, 28)
                    .offset(y: appearAnimation ? 0 : 30)
                    .opacity(appearAnimation ? 1.0 : 0)
                    
                    Spacer()
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    appearAnimation = true
                }
            }
            .navigationDestination(isPresented: $showGameScreen) {
                GameView(category: selectedCategory)
                    .environmentObject(langManager)
                    .environmentObject(scoreManager)
            }
            // Mode selection modal / モード選択モーダル
            .sheet(isPresented: $showCategoryPicker) {
                CategorySelectionSheet(
                    selectedCategory: $selectedCategory,
                    onSelect: { category in
                        selectedCategory = category
                        showCategoryPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                            showGameScreen = true
                        }
                    }
                )
                .environmentObject(langManager)
                .presentationDetents([.height(390)])
                .presentationCornerRadius(36)
            }
            .sheet(isPresented: $showRankingScreen) {
                RankingView()
                    .environmentObject(langManager)
                    .environmentObject(scoreManager)
            }
            .sheet(isPresented: $showSettingsScreen) {
                SettingsView()
                    .environmentObject(langManager)
            }
        }
    }
}

// MARK: - Trilingual Mode Selection Modal / 3言語対応のモード選択モーダル
struct CategorySelectionSheet: View {
    @EnvironmentObject var langManager: LanguageManager
    @Binding var selectedCategory: GameCategory
    var onSelect: (GameCategory) -> Void
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.10, blue: 0.18), Color(red: 0.07, green: 0.06, blue: 0.10)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 36, height: 5)
                    .padding(.top, 12)
                
                VStack(spacing: 4) {
                    Text(langManager.text(for: "select_mode"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(langManager.text(for: "subtitle_mode"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 6)
                
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        CategoryCard(
                            title: langManager.text(for: "mode_world"),
                            subtitle: langManager.text(for: "subtitle_world"),
                            icon: "globe.americas.fill",
                            gradientColors: [Color.green, Color.mint],
                            action: { onSelect(.world) }
                        )
                        
                        CategoryCard(
                            title: langManager.text(for: "mode_school"),
                            subtitle: langManager.text(for: "subtitle_school"),
                            icon: "graduationcap.fill",
                            gradientColors: [Color.blue, Color.cyan],
                            action: { onSelect(.school) }
                        )
                    }
                    
                    CategoryCard(
                        title: langManager.text(for: "mode_halloween"),
                        subtitle: langManager.text(for: "subtitle_halloween"),
                        icon: "sparkles",
                        gradientColors: [Color.orange, Color.purple],
                        isSpecial: true,
                        action: { onSelect(.halloween) }
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
        }
    }
}

// MARK: - Interactive Mode Card / インタラクティブなモードカード
struct CategoryCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let gradientColors: [Color]
    var isSpecial: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: gradientColors,
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 52, height: 52)
                            .shadow(color: gradientColors[0].opacity(0.5), radius: 10, x: 0, y: 5)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 3) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(subtitle)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.65))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: isSpecial ? [.orange, .purple] : [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isSpecial ? 2 : 1
                                )
                        )
                )
                .shadow(color: isSpecial ? Color.orange.opacity(0.25) : Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                
                if isSpecial {
                    Text("EVENT")
                        .font(.system(size: 9, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        )
                        .shadow(color: .orange.opacity(0.5), radius: 4)
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Touch Press Animation (Premium Spring Effect) / タッチプレスアニメーション（高品質スプリング効果）
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

#Preview {
    ContentView(isFinishedSplash: .constant(true))
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
