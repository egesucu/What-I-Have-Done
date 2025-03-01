//
//  What_I_Have_DoneApp.swift
//  What I Have Done
//
//  Created by Sucu, Ege on 1.03.2025.
//

import SwiftUI

@main
struct What_I_Have_DoneApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
