//
//  ActivityAnalyzer.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 15.03.2025.
//

import Foundation
import NaturalLanguage

class ActivityAnalyzer {
    static func analyze(input: String) -> (title: String, category: ActivityCategory?, date: Date?) {
        let words = input.lowercased().components(separatedBy: " ")
        var detectedCategory: ActivityCategory?
        var detectedDate: Date?
        
        // Use NLP for keyword extraction
        let extractedKeywords = extractKeywords(from: input)
        
        // Improved category detection with lemmatization
        let categoryMap: [String: ActivityCategory] = [
            "work": .work,
            "exercise": .exercise, "gym": .exercise, "fitness": .exercise,
            "errands": .home, "shopping": .home, "groceries": .home,
            "reading": .reading, "book": .reading, "study": .reading,
            "meditation": .mindfulness, "yoga": .mindfulness, "ran": .exercise, "hiked": .exercise, "swam": .exercise
        ]
        
        for keyword in extractedKeywords {
            if let category = categoryMap[keyword.localizedLowercase] {
                detectedCategory = category
                break
            }
        }
        
        // Extract and parse dates
        detectedDate = extractDate(from: input)
        
        return (title: input, category: detectedCategory, date: detectedDate)
    }
    
    /// Uses NLP to extract meaningful keywords
    private static func extractKeywords(from text: String) -> [String] {
        let tagger = NLTagger(tagSchemes: [.lemma])
        tagger.string = text
        
        var keywords: [String] = []
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lemma,
            options: [.omitPunctuation, .omitWhitespace]
        ) { tag, tokenRange in
            if let lemma = tag?.rawValue {
                keywords.append(lemma.lowercased())
            }
            return true
        }
        return keywords
    }
    
    /// Extracts date using Natural Language Processing, supporting absolute and relative dates
    private static func extractDate(from text: String) -> Date? {
        let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue)
        let matches = detector?.matches(in: text, options: [], range: NSRange(location: 0, length: text.utf16.count))
        
        if let detectedDate = matches?.first?.date {
            return detectedDate
        }

        // Handle relative date expressions using NLTagger
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        let calendar = Calendar.current
        var computedDate: Date?

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass,
            options: [.omitPunctuation, .omitWhitespace]
        ) { tag, tokenRange in
            let word = String(text[tokenRange])
            
            switch word.lowercased() {
            case "today":
                computedDate = Date()
            case "yesterday":
                computedDate = calendar.date(byAdding: .day, value: -1, to: Date())
            case "tomorrow":
                computedDate = calendar.date(byAdding: .day, value: 1, to: Date())
            case "weekend":
                computedDate = calendar.nextWeekend(startingAfter: Date())?.start
            case "last":
                if let nextWordRange = text.range(of: word)?.upperBound {
                    let nextWord = text[nextWordRange...].split(separator: " ").first?.lowercased()
                    if let nextWord = nextWord, let weekday = weekdayFromString(nextWord) {
                        computedDate = lastOccurrence(of: weekday)
                    }
                }
            case "next":
                if let nextWordRange = text.range(of: word)?.upperBound {
                    let nextWord = text[nextWordRange...].split(separator: " ").first?.lowercased()
                    if let nextWord = nextWord, let weekday = weekdayFromString(nextWord) {
                        computedDate = nextOccurrence(of: weekday)
                    }
                }
            default:
                break
            }
            return true
        }
        
        return computedDate
    }
    
    /// Returns the next occurrence of a given weekday
    private static func nextOccurrence(of weekday: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToAdd = (weekday - todayWeekday + 7) % 7
        return calendar.date(byAdding: .day, value: daysToAdd, to: today)
    }
    
    /// Returns the last occurrence of a given weekday
    private static func lastOccurrence(of weekday: Int) -> Date? {
        let calendar = Calendar.current
        let today = Date()
        let todayWeekday = calendar.component(.weekday, from: today)
        let daysToSubtract = (todayWeekday - weekday + 7) % 7
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: today)
    }
    
    /// Converts a weekday string (e.g., "Monday") into a Calendar weekday integer
    private static func weekdayFromString(_ day: String) -> Int? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        if let date = formatter.date(from: day.capitalized) {
            return Calendar.current.component(.weekday, from: date)
        }
        return nil
    }
}
