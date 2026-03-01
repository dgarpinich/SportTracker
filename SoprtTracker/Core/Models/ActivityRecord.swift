//
//  ActivityRecord.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 22.02.2026.
//

import Foundation

struct ActivityRecord: Identifiable, Codable {
    var id: UUID = UUID()
    let title: String
    let location: String
    let durationInMinutes: Int
    var date: Date = Date()
    let storageType: StorageType
    
    var formattedDuration: String {
        let duration: Duration = .seconds(durationInMinutes * 60)
        return duration.formatted(.units(width: .narrow))
    }
}
