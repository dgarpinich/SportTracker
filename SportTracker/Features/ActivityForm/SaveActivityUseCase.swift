//
//  SaveActivityUseCase.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 18.03.2026.
//

import Foundation

enum SaveActivityResult {
    case success
    case failure(String)
}

protocol SaveActivityUseCaseProtocol {
    func execute(_ formData: ActivityRecord) async -> SaveActivityResult
}

final class SaveActivityUseCase: SaveActivityUseCaseProtocol {
    private let repository: any ActivityRepositoryProtocol
    
    init(repository: any ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ record: ActivityRecord) async -> SaveActivityResult {
        do {
            try await repository.saveRecord(record)
            return .success
        } catch {
            return .failure("Failed to save activity: \(error.localizedDescription)")
        }
    }
}
