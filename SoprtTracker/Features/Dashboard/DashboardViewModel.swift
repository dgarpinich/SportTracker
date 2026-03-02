//
//  DashboardViewModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 23.02.2026.
//

import Foundation
import Observation

@Observable
final class DashboardViewModel {
    private(set) var state: State = .loading
    private(set) var destination: Destination?
    
    private let repository: ActivityRepositoryProtocol
    
    private var currentFilter: ActivityFilter = .all
    private var allRecords: [ActivityRecord] = []
    
    init (repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    @MainActor
    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchActivities()
            
        case .tapAddActivity:
            destination = .form(ActivityFormViewModel(repository: repository))
            
        case .dissmissForm:
            destination = nil
            fetchActivities()
            
        case .dismissWarningAlert:
            if case .success(let records, let filter, _) = state {
                state = .success(records, filter: filter, warningMessage: nil)
            }
            
        case .setFilter(let newFilter):
            currentFilter = newFilter
            
            let filteredRecords =  applyCurrentFilter()
        
            state = .success(
                filteredRecords,
                filter: currentFilter,
                warningMessage: nil
            )
        }
        
    }
    
    @MainActor
    private func fetchActivities() {
        state = .loading
        Task {
            do {
                allRecords = try await repository.fetchRecords()
                let filteredRecords =  applyCurrentFilter()
                
                state = .success(
                    filteredRecords,
                    filter: currentFilter,
                    warningMessage: nil
                )
                
            } catch let error as RepositoryError {
                if case .networkError(let partialData) = error {
                    state = .success(
                        partialData,
                        filter: currentFilter,
                        warningMessage: error.localizedDescription
                    )
                }
            } catch {
                state = .error("Failed to load data: \(error.localizedDescription)")
            }
        }
    }
    
    private func applyCurrentFilter() -> [ActivityRecord] {
        
        switch currentFilter {
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
        case dissmissForm
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
