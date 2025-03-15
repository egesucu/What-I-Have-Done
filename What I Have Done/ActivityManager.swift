//
//  ActivityManager.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 2.03.2025.
//

import Foundation
import CoreData

@MainActor
class ActivityManager: ObservableObject {
    static let shared = ActivityManager(context: PersistenceController.shared.container.viewContext)
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    // MARK: - Save Activity
    func saveActivity(title: String, category: ActivityCategory, date: Date, notes: String? = nil) async throws {
        let activity = Activity(context: context)
        activity.id = UUID()
        activity.title = title
        activity.categoryRaw = category.rawValue
        activity.date = date
        
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    // MARK: - Fetch Activities
    func getActivities(filter: ActivityFilter) async throws -> [Activity] {
        let request: NSFetchRequest<Activity> = Activity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Activity.date, ascending: false)]
        
        var predicates: [NSPredicate] = []
        
        if let category = filter.category {
            predicates.append(NSPredicate(format: "categoryRaw == %@", category.rawValue))
        }
        if let dateRange = filter.dateRange {
            predicates.append(NSPredicate(format: "date >= %@ AND date <= %@", dateRange.start as NSDate, dateRange.end as NSDate))
        }
        if let keyword = filter.keyword, !keyword.isEmpty {
            predicates.append(NSPredicate(format: "title CONTAINS[cd] %@ OR notes CONTAINS[cd] %@", keyword, keyword))
        }
        
        if !predicates.isEmpty {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        }
        
        do {
            return try context.fetch(request)
        } catch {
            throw error
        }
    }
    
    // MARK: - Analyze Activities
    func analyzeActivities() async throws -> ActivityAnalysis {
        let activities = try await getActivities(filter: ActivityFilter())
        
        let streaks = StreakTracker.calculateStreaks(activities: activities)
        let categoryStats = CategoryAnalyzer.mostFrequentCategories(activities: activities)
        let totalLoggedTime = activities.count // Assuming each log is a unit of time
        
        return ActivityAnalysis(streaks: streaks, categoryStats: categoryStats, totalLoggedTime: totalLoggedTime)
    }
}

// MARK: - Supporting Structures

struct ActivityFilter {
    var category: ActivityCategory?
    var dateRange: (start: Date, end: Date)?
    var keyword: String?
}

struct ActivityAnalysis {
    let streaks: [Streak] // Array of streak data
    let categoryStats: [ActivityCategory: Int] // Category frequency
    let totalLoggedTime: Int // Total number of activities logged
}

struct Streak {
    let startDate: Date
    let endDate: Date
    let count: Int // Number of consecutive days logged
}

// MARK: - Analysis Helpers

class StreakTracker {
    static func calculateStreaks(activities: [Activity]) -> [Streak] {
        // Logic to determine streaks
        return []
    }
}

class CategoryAnalyzer {
    static func mostFrequentCategories(activities: [Activity]) -> [ActivityCategory: Int] {
        var categoryCount: [ActivityCategory: Int] = [:]
        for activity in activities {
            let category = ActivityCategory(rawValue: activity.categoryRaw ?? ActivityCategory.other.rawValue) ?? .other
            categoryCount[category, default: 0] += 1
        }
        return categoryCount
    }
}


