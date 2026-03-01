//
//  MockActivityRepository.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 22.02.2026.
//

import Foundation

final class MockActivityRepository: ActivityRepositoryProtocol {
    
    private var records: [ActivityRecord] = [
            ActivityRecord(
                title: "Running",
                location: "Park",
                durationInMinutes: 45,
                date: Date().addingTimeInterval(-86400),
                storageType: .remote
            ),
            ActivityRecord(
                title: "Swimming",
                location: "Swimming pool",
                durationInMinutes: 120,
                date: Date().addingTimeInterval(-172800),
                storageType: .local
            )
        ]
    
    private var errorToThrow: Error?
    private var delayNanoseconds: UInt64
    
    init(delayNanoseconds: UInt64 = 1_000_000_000) {
        self.delayNanoseconds = delayNanoseconds
    }
    
    func setError(_ error: Error?) { errorToThrow = error }
    func setRecords(_ newRecords: [ActivityRecord]) async { records = newRecords }
    
    func fetchRecords() async throws -> [ActivityRecord] {
        if let error = errorToThrow { throw error }
        if delayNanoseconds > 0 { try await Task.sleep(nanoseconds: delayNanoseconds) }
        return records.sorted { $0.date > $1.date }
    }
    
    func saveRecord(_ record: ActivityRecord) async throws {
        if let error = errorToThrow { throw error }
        if delayNanoseconds > 0 { try await Task.sleep(nanoseconds: delayNanoseconds) }
        records.append(record)
    }
}
