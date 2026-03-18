//
//  AppActivityRepository.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation

final class AppActivityRepository: ActivityRepositoryProtocol {
    private let localService: any ActivityDataSourceProtocol
    private let remoteService: any ActivityDataSourceProtocol
    
    init(localService: any ActivityDataSourceProtocol, remoteService: any ActivityDataSourceProtocol) {
        self.localService = localService
        self.remoteService = remoteService
    }
    
    func saveRecord(_ record: ActivityRecord) async throws {
        switch record.storageType {
        case .local:
            try await localService.save(record)
        case .remote:
            try await remoteService.save(record)
        }
    }
    
    func fetchRecords() async throws -> [ActivityRecord]  {
        async let localRecordsTask = localService.fetchAll()
        async let remoteRecordsTask = remoteService.fetchAll()
        
        let localRecords = (try? await localRecordsTask) ?? []
        
        do {
            let remoteRecords = try await remoteRecordsTask
            
            
            let allRecrods = localRecords + remoteRecords
            return allRecrods.sorted(by: { $0.date > $1.date })
        } catch {
            throw RepositoryError.networkError(partialData: localRecords)
        }
    }
}


