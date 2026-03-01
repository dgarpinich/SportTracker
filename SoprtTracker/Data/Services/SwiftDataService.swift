//
//  SwiftDataService.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation
import SwiftData

final class SwiftDataService: ActivityDataSourceProtocol {
    private let container: ModelContainer
    
    init(container: ModelContainer) {
        self.container = container
    }
    
    func save(_ record: ActivityRecord) async throws {
        let context = ModelContext(container)
        
        let model = LocalActivityModel(from: record)
        
        context.insert(model)
        try context.save()
    }
    
    func fetchAll() async throws -> [ActivityRecord] {
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<LocalActivityModel>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        
        let models = try context.fetch(descriptor)
        
        return models.map(\.toActivityRecord)
    }
}
