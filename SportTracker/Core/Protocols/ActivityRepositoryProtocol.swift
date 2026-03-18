//
//  ActivityRepositoryProtocol.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 22.02.2026.
//

import Foundation

protocol ActivityRepositoryProtocol {
    func fetchRecords() async throws -> [ActivityRecord]
    func saveRecord(_ record: ActivityRecord) async throws
}
