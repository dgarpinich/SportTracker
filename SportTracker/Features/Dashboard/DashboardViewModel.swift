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
    
    private let fetchActivitiesUseCase: any FetchActivitiesUseCaseProtocol
    
    private let makeFormViewModel: () -> ActivityFormViewModel
    
    private var filter: ActivityFilter = .all
    private var allRecords: [ActivityRecord] = []
    
    init (
        fetchActivitiesUseCase: any FetchActivitiesUseCaseProtocol,
        makeFormViewModel: @escaping () -> ActivityFormViewModel
    ) {
        self.fetchActivitiesUseCase = fetchActivitiesUseCase
        self.makeFormViewModel = makeFormViewModel
    }

    func send(_ action: Action) {
        switch action {
        case .onAppear:
            fetchActivities()
            
        case .tapAddActivity:
            destination = .form(makeFormViewModel())
            
        case .dismissForm(let didSave):
            guard destination != nil else { return }
            
            destination = nil
            if didSave { fetchActivities() }
            
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
        
        Task {
            switch await fetchActivitiesUseCase.execute() {
            case .success(let records):
                allRecords = records
                
                state = .success(
                    applyFilter(),
                    filter: filter,
                    warningMessage: nil
                )
                
            case .partialSuccess(let partialData, let warningMessage):
                allRecords = partialData
                
                state = .success(
                    applyFilter(),
                    filter: filter,
                    warningMessage: warningMessage
                )
                
            case .failure(let message):
                state = .error(message)
            }
        }
    }
    
    private func applyFilter() -> [ActivityRecord] {
        switch filter {
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
        case dismissForm(Bool)
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

