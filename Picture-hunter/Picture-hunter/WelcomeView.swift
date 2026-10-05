import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var isFinished: Bool
    
    @State private var isAnimating = false
    @State private var pulseText = false
    @State private var pulseFlower = false // Dedicated pulse animation for the flower icon
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.3),
                    Color(red: 0.25, green: 0.15, blue: 0.45)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Ambient glowing circles
            Circle()
                .fill(Color.blue.opacity(0.65))
                .frame(width: 250, height: 250)
                .blur(radius: 50)
                .offset(x: isAnimating ? -80 : 80, y: isAnimating ? -120 : -60)
            
            Circle()
                .fill(Color.purple.opacity(0.65))
                .frame(width: 300, height: 300)
                .blur(radius: 60)
                .offset(x: isAnimating ? 100 : -50, y: isAnimating ? 150 : 80)
            
            VStack(spacing: 30) {
                Spacer()
                
                // Glassmorphism Logo
                ZStack {
                    RoundedRectangle(cornerRadius: 30)
                        .fill(Color.white.opacity(0.12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 10)
                    
                    Image(systemName: "camera.macro")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 85, height: 85)
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.6), radius: 10)
                        .scaleEffect(pulseFlower ? 1.15 : 0.85) // Scale up/down animation for the flower
                }
                .frame(width: 150, height: 150)
                
                // Main Title
                VStack(spacing: 8) {
                    Text("Picture Hunter")
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.white.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                
                Spacer()
                
                // Tap prompt (automatically adapts to selected language)
                VStack(spacing: 12) {
                    Text(languageManager.text(for: "tap_to_start")) // Corrected dictionary key in lowercase
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.18))
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(0.4), lineWidth: 1)
                                )
                        )
                        .scaleEffect(pulseText ? 1.05 : 0.98)
                        .opacity(pulseText ? 1.0 : 0.7)
                    
                    Image(systemName: "chevron.compact.down")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .offset(y: pulseText ? 7 : -4)
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal)
        }
        .onAppear {
            // Background circles
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
            // Bottom text prompt
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseText = true
            }
            // Flower / Logo (faster pulse)
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseFlower = true
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.5)) {
                isFinished = true
            }
        }
    }
}

#Preview {
    WelcomeView(isFinished: .constant(false))
        .environmentObject(LanguageManager())
}
