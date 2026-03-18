//
//  FetchActivitiesUseCase.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 18.03.2026.
//

import Foundation

enum FetchActivitiesResult {
    case success([ActivityRecord])
    case partialSuccess([ActivityRecord], warningMessage: String)
    case failure(String)
    
}

protocol FetchActivitiesUseCaseProtocol {
    func execute() async -> FetchActivitiesResult
}

final class FetchActivitiesUseCase: FetchActivitiesUseCaseProtocol {
    private let repository: any ActivityRepositoryProtocol
    
    init(repository: any ActivityRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async -> FetchActivitiesResult {
        do {
            let records = try await repository.fetchRecords()
            return .success(records)
            
        } catch {
            if let repoError = error as? RepositoryError,
                case .networkError(let partialData) = repoError {
                
                return .partialSuccess(partialData, warningMessage: error.localizedDescription)
            }
            
            return .failure(error.localizedDescription)
        }
    }
}
