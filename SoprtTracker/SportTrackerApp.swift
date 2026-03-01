//
//  SportTrackerApp.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 22.02.2026.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct SportTrackerApp: App {
    let container: ModelContainer
    
    @State private var dashboardViewModel: DashboardViewModel
    
    init() {
        FirebaseApp.configure()
        
        do {
            container = try ModelContainer(for: LocalActivityModel.self)
            let context = container.mainContext
            
            let localService = SwiftDataService(context: context)
            let remoteService = FirestoreService()
            
            let commonRepository = AppActivityRepository(localService: localService, remoteService: remoteService)
            
            _dashboardViewModel = State(initialValue: .init(repository: commonRepository))
            
        } catch {
            fatalError("Failed to initialize SwiftData: \(error.localizedDescription)")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: dashboardViewModel)
        }
    }
}
