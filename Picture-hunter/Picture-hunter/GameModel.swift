//
//  GameModel.swift
//  LocationHunter
//
//  Created by cmStudent on 2026/09/30.
//

import Foundation

struct Question {
    let id = UUID()
    let imageName: String      // Nom de l'image dans Assets
    let answerJa: String       // Réponse en Japonais
    let answerEn: String       // Réponse en Anglais
    let answerMy: String       // Réponse en Myanmar
    let hints: [String]        // Indices éventuels
}


