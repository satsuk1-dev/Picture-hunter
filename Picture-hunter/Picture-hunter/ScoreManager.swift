import Foundation
import SwiftUI
import Combine

struct RankingItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let score: Int
    let date: Date
}

class ScoreManager: ObservableObject {
    @Published var highScores: [RankingItem] = []
    
    private let saveKey = "SavedHighScores"
    
    init() {
        loadScores()
    }
    
    func loadScores() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([RankingItem].self, from: data) {
            
            // 本日（今日）登録されたデータのみに絞り込む
            let calendar = Calendar.current
            self.highScores = decoded.filter { calendar.isDateInToday($0.date) }
        }
    }
    
    func addScore(name: String, score: Int) {
        let newEntry = RankingItem(name: name, score: score, date: Date())
        highScores.append(newEntry)
        
        // 今日のデータのみをスコア順に並び替え
        let calendar = Calendar.current
        highScores = highScores
            .filter { calendar.isDateInToday($0.date) }
            .sorted { $0.score > $1.score }
        
        // TOP 10 のみを保持
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
        
        saveScores()
    }
    
    func resetScores() {
        highScores.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
