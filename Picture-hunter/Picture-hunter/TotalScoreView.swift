//
//  TotalScoreView.swift
//  Picture hunter
//
//  Created by cmStudent on 2026/10/08.
//

//
//  TotalscoreView.swift
//  LocationHunter
//
//  Created by cmStudent on 2026/10/07.
//

import SwiftUI

struct TotalscoreView: View {
    var score: Int
    var correctAnswers: Int
    var totalQuestions: Int
    var bestScore: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Text("Total")
                .font(.system(size: 55))
                .fontWeight(.regular)
            Text("PICTURE HUNTER")
                .font(.title3)
//           Text("結果")
//                .font(.title2)
//            Image(systemName: "trophy.fill")
//                .font(.system(size: 65))
//                .padding(.top, 10)
            Text(" TOTAL SCORE")
                .font(.headline)
            
            Text("\(score)")
                .font(.system(size: 90, weight: .regular))
                .foregroundStyle(score >= 500 ? .green : .red)
            Text("POINT")
                .font(.headline)
                .foregroundStyle(.secondary)
            Divider()
                .padding(.horizontal, 30)
            HStack(spacing: 50) {
                VStack(spacing: 8) {
                    Text("正解数")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(correctAnswers)/\(totalQuestions)")
                        .font(.title)
                        .bold()
                }

                VStack(spacing: 8) {
                    Text("BEST SCORE")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(bestScore)")
                        .font(.title)
                        .bold()
                }//VStack
            }//HStack
            Text(resultMessage)
                .font(.title3)
                .bold()
                .foregroundStyle(score >= 500 ? .green : .red)
            Spacer()
            
            HStack(spacing: 15) {
                Button {
                    // ホーム画面への移動はあとで設定
                    dismiss()
                } label: {
                    Label("ホームに戻る", systemImage: "house")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.bordered)

                Button {
                    // GameViewへの移動はあとで設定
                } label: {
                    Label("もう一度プレイ", systemImage: "arrow.clockwise")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                // RankingViewへの移動はあとで設定
            } label: {
                Label("ランキングを見る", systemImage: "list.number")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.bordered)
        }//一番上のvstack
        
        .padding(30)
    }
    
    
    var resultMessage: String {
        if score >= 800 {
            return "Excellent! 🎉"
        } else if score >= 500 {
            return "Good Job! 👏"
        } else {
            return "Try Again! 💪"
        }
    }
}
#Preview {
   TotalscoreView(
    score: 800,
                  correctAnswers: 8,
                  totalQuestions: 10,
                  bestScore: 950
    
   )
}

