//
//  SwiftDataService.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation
import SwiftData

@MainActor
final class SwiftDataService: ActivityDataSourceProtocol {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func save(_ record: ActivityRecord) async throws {
        let model = LocalActivityModel(from: record)
        context.insert(model)
        try context.save()
    }
    
    func fetchAll() async throws -> [ActivityRecord] {
        let descriptor = FetchDescriptor<LocalActivityModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let models = try context.fetch(descriptor)
        return models.map(\.toActivityRecord)
    }
}
