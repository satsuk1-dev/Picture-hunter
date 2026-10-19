import Foundation
import SwiftUI
import Combine

struct RankingItem: Identifiable, Codable {
    var id = UUID()
    let name: String
    let score: Int
    let category: String 
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
            let calendar = Calendar.current
            // Conservons uniquement les données enregistrées aujourd'hui
            self.highScores = decoded.filter { calendar.isDateInToday($0.date) }
        }
    }
    
    /// Filtrage strict par catégorie sélectionnée
    func scores(for category: String) -> [RankingItem] {
        let calendar = Calendar.current
        return highScores
            .filter { $0.category == category && calendar.isDateInToday($0.date) }
            .sorted { $0.score > $1.score }
    }
    
    /// Ajout d'un score avec sa catégorie explicite
    func addScore(name: String, score: Int, category: String) {
        let newEntry = RankingItem(name: name, score: score, category: category, date: Date())
        highScores.append(newEntry)
        
        let calendar = Calendar.current
        highScores = highScores
            .filter { calendar.isDateInToday($0.date) }
            .sorted { $0.score > $1.score }
        
        saveScores()
    }
    
    /// Réinitialise une seule catégorie
    func resetScores(for category: String) {
        highScores.removeAll { $0.category == category }
        saveScores()
    }
    
    /// Réinitialise TOUS les scores
    func resetAllScores() {
        highScores.removeAll()
        UserDefaults.standard.removeObject(forKey: saveKey)
    }
    
    func resetScores() {
        resetAllScores()
    }
    
    private func saveScores() {
        if let encoded = try? JSONEncoder().encode(highScores) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
