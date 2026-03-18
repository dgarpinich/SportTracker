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
    
    private let commonRepository: any ActivityRepositoryProtocol
    
    init() {
        FirebaseApp.configure()
        
        do {
            container = try ModelContainer(for: LocalActivityModel.self)
            
            let localService = SwiftDataService(container: container)
            let remoteService = FirestoreService()
            
            commonRepository = AppActivityRepository(localService: localService, remoteService: remoteService)
        } catch {
            fatalError("Failed to initialize SwiftData: \(error.localizedDescription)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            DashboardView(viewModel: makeDashboardViewModel())
        }
    }
    
    private func makeDashboardViewModel() -> DashboardViewModel {
        DashboardViewModel(
            fetchActivitiesUseCase: FetchActivitiesUseCase(repository: commonRepository),
            makeFormViewModel: makeFormViewModel
        )
    }
    
    private func makeFormViewModel() -> ActivityFormViewModel {
        ActivityFormViewModel(
            saveActivityUseCase: SaveActivityUseCase(repository: commonRepository)
        )
    }
}
