//
//  AnalyzingView.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 15.03.2025.
//

import SwiftUI

struct AnalyzingView: View {
    let input: String
    var completion: ((title: String, category: ActivityCategory?, date: Date?)) -> Void

    @State private var progress: Double = 0.0
    @State private var isComplete: Bool = false
    
    var body: some View {
        VStack {
            ProgressView("Analyzing your input...", value: progress, total: 1.0)
                .padding()
            
            if isComplete {
                Text("Analysis Complete!")
                    .font(.headline)
                    .foregroundColor(.green)
            }
        }
        .onAppear {
            analyzeInput()
        }
    }
    
    private func analyzeInput() {
        Task {
            for i in 1...10 {
                try await Task.sleep(nanoseconds: 200_000_000) // Simulate delay
                progress = Double(i) / 10.0
            }
            
            let analysisResult = ActivityAnalyzer.analyze(input: input)
            completion(analysisResult)
        }
    }
}
