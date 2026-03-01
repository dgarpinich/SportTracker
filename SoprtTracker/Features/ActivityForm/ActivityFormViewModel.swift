//
//  ActivityFormViewModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 25.02.2026.
//

import Foundation
import Observation

@Observable
final class ActivityFormViewModel {
    private(set) var state: State = .idle
    private let repository: ActivityRepositoryProtocol
    
    init (repository: ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func send(_ action: Action) async -> Bool {
        switch action {
        case .save(let formData):
            return await saveActivity(formData)
        }
    }
    
    private func saveActivity(_ formData: FormData) async -> Bool {
        state = .loading
        
        do {
            try await repository.saveRecord(formData.toRecord)
            
            state = .idle
            return true
        } catch {
            state = .error("Failed to save activity: \(error.localizedDescription)")
            return false
        }
    }
}

extension ActivityFormViewModel: Identifiable {
    var id: ObjectIdentifier { ObjectIdentifier(self) }
    
    enum State {
        case idle
        case loading
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
