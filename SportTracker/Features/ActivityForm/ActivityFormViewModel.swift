//
//  ActivityFormViewModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 25.02.2026.
//

import Foundation
import Observation

@MainActor
@Observable
final class ActivityFormViewModel {
    private(set) var state: State = .idle
    private let repository: any ActivityRepositoryProtocol
    
    init (repository: any ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func send(_ action: Action) {
        switch action {
        case .save(let formData):
            Task { await saveActivity(formData) }
        }
    }
    
    private func saveActivity(_ formData: FormData) async {
        state = .loading
        
        do {
            try await repository.saveRecord(formData.toRecord)
            state = .saved
        } catch {
            state = .error("Failed to save activity: \(error.localizedDescription)")
        }
    }
}

extension ActivityFormViewModel {
    
    enum State: Equatable{
        case idle
        case loading
        case saved
        case error(String)
    }
    
    struct FormData {
        let title: String
        let location: String
        let duration: Int
        let storageType: StorageType
        
        var toRecord: ActivityRecord {
            ActivityRecord(
                title: title,
                location: location,
                durationInMinutes: duration,
                storageType: storageType
            )
        }
    }
    
    enum Action {
        case save(FormData)
    }
}
