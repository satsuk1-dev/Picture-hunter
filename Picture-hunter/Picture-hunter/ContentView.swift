import SwiftUI

struct ContentView: View {
    @EnvironmentObject var langManager: LanguageManager
    @EnvironmentObject var scoreManager: ScoreManager
    
    @Binding var isFinishedSplash: Bool
    
    @State private var selectedDifficulty: Difficulty = .medium
    @State private var showGameScreen = false
    @State private var showRankingScreen = false
    @State private var showSettingsScreen = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.8)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 35) {
                    HStack {
                        Button(action: {
                            withAnimation(.easeInOut) {
                                isFinishedSplash = false
                            }
                        }) {
                            Image(systemName: "house.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    Spacer()
                    
                    VStack(spacing: 12) {
                        Image(systemName: "camera.macro")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                        
                        Text(langManager.text(for: "app_title"))
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(langManager.text(for: "subtitle"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 6)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    VStack(spacing: 18) {
                        Button(action: { showGameScreen = true }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text(langManager.text(for: "start")).fontWeight(.bold)
                            }
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        
                        Button(action: { showRankingScreen = true }) {
                            HStack {
                                Image(systemName: "trophy.fill")
                                Text(langManager.text(for: "ranking")).fontWeight(.bold)
                            }
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(20)
                        }
                        
                        Button(action: { showSettingsScreen = true }) {
                            HStack {
                                Image(systemName: "gearshape.fill")
                                Text(langManager.text(for: "settings")).fontWeight(.bold)
                            }
                            .font(.title3)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.white.opacity(0.25))
                            .cornerRadius(20)
                        }
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                }
            }
            // Transition vers GameView lors du clic sur START
            .navigationDestination(isPresented: $showGameScreen) {
                GameView()
                    .environmentObject(langManager)
            }
            // Modale de classement (RankingView)
            .sheet(isPresented: $showRankingScreen) {
                RankingView()
                    .environmentObject(langManager)
                    .environmentObject(scoreManager)
            }
            // Modale de réglages
            .sheet(isPresented: $showSettingsScreen) {
                SettingsView(selectedDifficulty: $selectedDifficulty)
                    .environmentObject(langManager)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView(isFinishedSplash: .constant(true))
        .environmentObject(LanguageManager())
        .environmentObject(ScoreManager())
}
