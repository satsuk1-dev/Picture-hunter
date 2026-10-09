import SwiftUI

// MARK: - 星の形（中心にくびれた4方向の星）
struct SparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        let c = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: CGPoint(x: c.x, y: rect.minY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: c.y), control: c)
        path.addQuadCurve(to: CGPoint(x: c.x, y: rect.maxY), control: c)
        path.addQuadCurve(to: CGPoint(x: rect.minX, y: c.y), control: c)
        path.addQuadCurve(to: CGPoint(x: c.x, y: rect.minY), control: c)
        path.closeSubpath()
        return path
    }
}

// MARK: - 星1つ分のデータ
struct StarItem: Identifiable {
    let id = UUID()
    let position: CGPoint
    let size: CGFloat
    let rotation: Double
    let duration: Double
}

// MARK: - 星1つの表示（ぱっと出て、ゆっくり消える）
struct StarView: View {
    let item: StarItem
    @State private var scale: CGFloat = 0.3
    @State private var opacity: Double = 0.0

    var body: some View {
        SparkleShape()
            .fill(Color.white)
            .frame(width: item.size, height: item.size)
            .shadow(color: .white.opacity(0.8), radius: item.size * 0.3)
            .rotationEffect(.degrees(item.rotation))
            .scaleEffect(scale)
            .opacity(opacity)
            .position(item.position)
            .task {
                // ぱっと出る
                withAnimation(.easeOut(duration: 0.1)) {
                    scale = 1.0
                    opacity = 0.9
                }
                try? await Task.sleep(for: .seconds(0.1))
                // ゆっくり消える
                withAnimation(.easeIn(duration: item.duration)) {
                    scale = 0.5
                    opacity = 0.0
                }
            }
    }
}

// MARK: - ランダムに星を出す背景
struct StarField: View {
    @State private var items: [StarItem] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(items) { item in
                    StarView(item: item)
                }
            }
            .task {
                while !Task.isCancelled {
                    spawn(in: geo.size)
                    // 星を出す間隔（ゆっくりめ）
                    try? await Task.sleep(for: .seconds(Double.random(in: 0.8...1.8)))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func spawn(in size: CGSize) {
        let item = StarItem(
            position: CGPoint(x: .random(in: 20...(size.width - 20)),
                              y: .random(in: 60...(size.height - 60))),
            size: .random(in: 28...28),          // 小さめの星
            rotation: .random(in: -20...20),
            duration: .random(in: 0.8...1.4)
        )
        items.append(item)

        // 役目を終えた星は配列から削除
        Task {
            try? await Task.sleep(for: .seconds(item.duration + 0.3))
            items.removeAll { $0.id == item.id }
        }
    }
}

// MARK: - ウェルカム画面
struct WelcomeView: View {
    @EnvironmentObject var languageManager: LanguageManager
    @Binding var isFinished: Bool

    @State private var pulseText = false
    @State private var flashOpacity: Double = 0.0

    var body: some View {
        ZStack {
            // 黒背景
            Color.black.ignoresSafeArea()
            
            RadialGradient(
                colors: [Color.white.opacity(0.35), Color.clear],
                center: UnitPoint(x: 0.5, y: 0.5),
                startRadius: 0,
                endRadius: 260
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            // 小さい星（ランダム）
            StarField()

            // 白いフラッシュ（控えめ・低頻度）
            Color.white
                .ignoresSafeArea()
                .opacity(flashOpacity)
                .allowsHitTesting(false)

            // タイトル（画面の中央）
            Text("Picture\nhunter")
                .font(.system(size: 80, weight: .regular, design: .default))
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.5)
                .foregroundColor(.white)
                .padding(.horizontal)

            // 下のボタン（画面の下に固定）
            VStack {
                Spacer()

                VStack(spacing: 12) {
                    // 変更後
                    Text(languageManager.text(for: "tap_to_start"))
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
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
        .contentShape(Rectangle())
        .onAppear {
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                pulseText = true
            }
        }
        .task {
            // 最初の光までの間
            try? await Task.sleep(for: .seconds(3.0))

            while !Task.isCancelled {
                // ぱっと光る（弱め）
                withAnimation(.easeOut(duration: 0.08)) {
                    flashOpacity = 0.3
                }
                try? await Task.sleep(for: .seconds(0.08))

                // ゆっくり消える
                withAnimation(.easeIn(duration: 1.0)) {
                    flashOpacity = 0.0
                }

                // 次の光までの待ち時間（長め）
                try? await Task.sleep(for: .seconds(Double.random(in: 7.0...12.0)))
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
