//
//  Persistence.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 1.03.2025.
//

import CoreData

final class PersistenceController {
    static let shared = PersistenceController() // Singleton instance

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let sampleActivities = [
            "I did bench press at the gym",
            "I completed a work report",
            "I went for a morning run",
            "I read a chapter of my book",
            "I cooked a new recipe for dinner",
            "I meditated for 10 minutes",
            "I attended a team meeting",
            "I practiced guitar",
            "I cleaned the house",
            "I went grocery shopping"
        ]
        
        for number in 0..<10 {
            let newActivity = Activity(context: viewContext)
            newActivity.id = UUID()
            newActivity.date = Calendar.current.date(byAdding: .day, value: -number, to: Date())!
            newActivity.title = sampleActivities[number % sampleActivities.count]
            newActivity.category = ActivityCategory.allCases.randomElement() ?? .home

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        return result
    }()

    let container: NSPersistentCloudKitContainer

    private init(inMemory: Bool = false) { // Private init to enforce singleton
        container = NSPersistentCloudKitContainer(name: "What_I_Have_Done")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
