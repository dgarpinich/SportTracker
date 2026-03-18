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
    private let saveActivityUseCase: any SaveActivityUseCaseProtocol
    
    init (saveActivityUseCase: any SaveActivityUseCaseProtocol) {
        self.saveActivityUseCase = saveActivityUseCase
    }
    
    func send(_ action: Action) {
        switch action {
        case .save(let formData):
            Task { await saveActivity(formData) }
        }
    }
    
    private func saveActivity(_ formData: FormData) async {
        state = .loading
        
        switch await saveActivityUseCase.execute(formData.toRecord) {
            case .success:
            state = .saved
        case .failure(let error):
            state = .error(error.localizedCapitalized)
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
