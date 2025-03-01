//
//  ActivityCategory.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 1.03.2025.
//

import Foundation

enum ActivityCategory: String, CaseIterable, Codable {
    case work = "Work"
    case reading = "Reading"
    case listening = "Listening"
    case exercise = "Exercise"
    case mindfulness = "Mindfulness"
    case home = "Home"
    case other = "Other"
    
    var icon: String {
        switch self {
        case .work: return "💼 Work"
        case .reading: return "📖 Reading"
        case .listening: return "🎧 Listening"
        case .exercise: return "🏋️ Exercise"
        case .mindfulness: return "🧘 Mindfulness"
        case .home: return "🏡 Home"
        case .other: return "✨ Other"
        }
    }
}
