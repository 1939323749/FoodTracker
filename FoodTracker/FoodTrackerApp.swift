//
//  FoodTrackerApp.swift
//  FoodTracker
//
//  Created by mba on 2023/10/15.
//

import SwiftUI
import SwiftData

@main
struct FoodTrackerApp: App {
    var sharedModelContainer:ModelContainer={
        let schema=Schema([
            Item.self,
        ])
        let modelConfiguration=ModelConfiguration(schema:schema,isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: modelConfiguration)
        }catch{
            fatalError("fail to create modelcontainer")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
