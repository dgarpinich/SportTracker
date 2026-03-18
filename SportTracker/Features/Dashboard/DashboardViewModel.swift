//
//  DashboardViewModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 23.02.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var state: State = .loading
    private(set) var destination: Destination?
    
    private let repository: any ActivityRepositoryProtocol
    
    private var filter: ActivityFilter = .all
    private var allRecords: [ActivityRecord] = []
    
    init (repository: any ActivityRepositoryProtocol) {
        self.repository = repository
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchActivities()
            
        case .tapAddActivity:
            destination = .form(ActivityFormViewModel(repository: repository))
            
        case .dismissForm:
            destination = nil
            fetchActivities()
            
        case .dismissWarningAlert:
            if case .success(let records, let filter, _) = state {
                state = .success(records, filter: filter, warningMessage: nil)
            }
            
        case .setFilter(let newFilter):
            filter = newFilter
            
            let filteredRecords = applyFilter()
        
            state = .success(
                filteredRecords,
                filter: filter,
                warningMessage: nil
            )
        }
        
    }
    
    private func fetchActivities() {
        state = .loading
        let currentFilter = filter
        
        Task {
            do {
                allRecords = try await repository.fetchRecords()
                let filteredRecords =  applyFilter(currentFilter)
                
                state = .success(
                    filteredRecords,
                    filter: currentFilter,
                    warningMessage: nil
                )
                
            } catch let error as RepositoryError {
                if case .networkError(let partialData) = error {
                    allRecords = partialData
                    let filteredRecords =  applyFilter(currentFilter)
                    
                    state = .success(
                        filteredRecords,
                        filter: currentFilter,
                        warningMessage: error.localizedDescription
                    )
                } else {
                    state = .error("Failed to load data: \(error.localizedDescription)")
                }
            } catch {
                state = .error("Failed to load data: \(error.localizedDescription)")
            }
        }
    }
    
    private func applyFilter(_ currentFilter: ActivityFilter? = nil) -> [ActivityRecord] {
        switch currentFilter ?? filter {
        case .all:
            allRecords
        case .local:
            allRecords.filter { $0.storageType == .local }
        case .remote:
            allRecords.filter { $0.storageType == .remote }
        }
        
    }
}

extension DashboardViewModel {

    enum State {
        case loading
        case success([ActivityRecord], filter: ActivityFilter,  warningMessage: String?)
        case error(String)
    }
    
    enum Action{
        case onAppear
        case tapAddActivity
        case dismissForm
        case dismissWarningAlert
        case setFilter(ActivityFilter)
    }
    
    enum Destination: Identifiable {
        case form(ActivityFormViewModel)
        
        var id: String {
            switch self {
            case .form:  "form"
            }
        }
    }
}

