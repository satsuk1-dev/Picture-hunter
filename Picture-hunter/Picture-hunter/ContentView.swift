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
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fond principal en dégradé
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.85), Color.blue.opacity(0.85)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header (Bouton Accueil)
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
                    
                    // Titre principal
                    VStack(spacing: 12) {
                        Image(systemName: "camera.macro")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        
                        Text(langManager.text(for: "app_title"))
                            .font(.system(size: 38, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                        
                        Text(langManager.text(for: "subtitle"))
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.9))
                            .padding(.horizontal, 18)
                            .padding(.vertical, 8)
                            .background(Capsule().fill(Color.white.opacity(0.2)))
                    }
                    
                    Spacer()
                    
                    // Menu principal
                    VStack(spacing: 16) {
                        Button(action: {
                            showCategoryPicker = true
                        }) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text(langManager.text(for: "start")).fontWeight(.black)
                            }
                            .font(.title2)
                            .foregroundColor(.purple)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white)
                            .cornerRadius(22)
                            .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
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
            .navigationDestination(isPresented: $showGameScreen) {
                GameView(category: selectedCategory)
                    .environmentObject(langManager)
                    .environmentObject(scoreManager)
            }
            // Modale recadrée sur les 3 cartes
            .sheet(isPresented: $showCategoryPicker) {
                CategorySelectionSheet(
                    selectedCategory: $selectedCategory,
                    onSelect: { category in
                        selectedCategory = category
                        showCategoryPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            showGameScreen = true
                        }
                    }
                )
                .environmentObject(langManager)
                .presentationDetents([.height(380)])
                .presentationCornerRadius(32)
            }
            .sheet(isPresented: $showRankingScreen) {
                RankingView()
                    .environmentObject(langManager)
                    .environmentObject(scoreManager)
            }
            .sheet(isPresented: $showSettingsScreen) {
                SettingsView(selectedDifficulty: $selectedDifficulty)
                    .environmentObject(langManager)
            }
        }
    }
}

// MARK: - Modale de Sélection Trilingue du Mode
struct CategorySelectionSheet: View {
    @EnvironmentObject var langManager: LanguageManager
    @Binding var selectedCategory: GameCategory
    var onSelect: (GameCategory) -> Void
    
    var body: some View {
        ZStack {
            // Fond sombre Apple Premium
            LinearGradient(
                colors: [Color(white: 0.12), Color(white: 0.08)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 16) {
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 38, height: 5)
                    .padding(.top, 12)
                
                // Textes multilingues dynamiques
                VStack(spacing: 4) {
                    Text(langManager.text(for: "select_mode"))
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(langManager.text(for: "subtitle_mode"))
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.6))
                }
                .padding(.bottom, 4)
                
                // Disposé proprement pour 3 cartes (2 en haut + 1 carte large centrée pour l'événement)
                VStack(spacing: 14) {
                    HStack(spacing: 14) {
                        // Mode École
                        CategoryCard(
                            title: langManager.text(for: "mode_school"),
                            subtitle: langManager.text(for: "subtitle_school"),
                            icon: "graduationcap.fill",
                            gradientColors: [Color.blue, Color.cyan],
                            action: { onSelect(.school) }
                        )
                        
                        // Mode Monde
                        CategoryCard(
                            title: langManager.text(for: "mode_world"),
                            subtitle: langManager.text(for: "subtitle_world"),
                            icon: "globe.americas.fill",
                            gradientColors: [Color.green, Color.mint],
                            action: { onSelect(.world) }
                        )
                    }
                    
                    // Mode Halloween centrée
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

// MARK: - Carte de Mode Interactive
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
                            .frame(width: 50, height: 50)
                            .shadow(color: gradientColors[0].opacity(0.4), radius: 8, x: 0, y: 4)
                        
                        Image(systemName: icon)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    VStack(spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        Text(subtitle)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.6))
                            .lineLimit(1)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .padding(.horizontal, 6)
                .background(
                    RoundedRectangle(cornerRadius: 22)
                        .fill(Color(white: 0.18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22)
                                .stroke(
                                    LinearGradient(
                                        colors: isSpecial ? [.orange, .purple] : [Color.white.opacity(0.15), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: isSpecial ? 2 : 1
                                )
                        )
                )
                .shadow(color: isSpecial ? Color.orange.opacity(0.2) : Color.black.opacity(0.25), radius: 8, x: 0, y: 4)
                
                if isSpecial {
                    Text("EVENT")
                        .font(.system(size: 8, weight: .black))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill(LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing))
                        )
                        .padding(.top, 8)
                        .padding(.trailing, 8)
                }
            }
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Animation d'Appui Tactile
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
