//
//  ActivityAddView.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 15.03.2025.
//

import SwiftUI

struct ActivityAddView: View {
    @Binding var isPresented: Bool
    @State private var inputText: String = ""
    @State private var isAnalyzing: Bool = false
    @State private var analyzedData: (title: String, category: ActivityCategory?, date: Date?)?
    
    var body: some View {
        VStack {
            if isAnalyzing {
                AnalyzingView(input: inputText) { result in
                    print("Analysis completed with result: \(result)")
                    self.analyzedData = result
                    saveActivity()
                }
            } else {
                topBarInputView
            }
        }
        .animation(.easeInOut, value: isAnalyzing)
        .onDisappear {
            resetView()
        }
    }
    
    private var topBarInputView: some View {
        HStack {
            TextField("What have you done?", text: $inputText)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    startAnalyzing()
                }
            
            Button("Send") {
                startAnalyzing()
            }
        }
        .padding()
    }
    
    private func startAnalyzing() {
        guard !inputText.isEmpty else { return }
        isAnalyzing = true
    }
    
    private func saveActivity() {
        guard let data = analyzedData else { return }
        
        Task {
            do {
                try await ActivityManager.shared.saveActivity(
                    title: data.title,
                    category: data.category ?? .other,
                    date: data.date ?? Date()
                )
                DispatchQueue.main.async {
                    isPresented = false // Dismiss the view after saving
                    isAnalyzing = false // Reset the analysis state
                }
            } catch {
                print("Error saving activity: \(error)")
            }
        }
    }
    
    private func resetView() {
        inputText = ""
        isAnalyzing = false
        analyzedData = nil
    }
}
