// ProposalCRMApp.swift
// Main entry point for the application

import SwiftUI

@main
struct ProposalCRMApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
