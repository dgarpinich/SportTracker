//
//  LocalActivityModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation
import SwiftData

@Model
final class LocalActivityModel {
    @Attribute(.unique) var id: UUID
    var title: String
    var location: String
    var durationInMinutes: Int
    var date: Date
    var storageTypeRaw: String
    
    
    init(id: UUID = UUID(), title: String, location: String, durationInMinutes: Int, date: Date, storageTypeRaw: String) {
        self.id = id
        self.title = title
        self.location = location
        self.durationInMinutes = durationInMinutes
        self.date = date
        self.storageTypeRaw = storageTypeRaw
    }
}

extension LocalActivityModel {
    
    convenience init(from record: ActivityRecord) {
        self.init(
            id: record.id,
            title: record.title,
            location: record.location,
            durationInMinutes: record.durationInMinutes,
            date: record.date,
            storageTypeRaw: record.storageType.rawValue
        )
    }
    
    var toActivityRecord: ActivityRecord {
        ActivityRecord(
            id: id,
            title: title,
            location: location,
            durationInMinutes: durationInMinutes,
            date: date,
            storageType: StorageType(rawValue: storageTypeRaw) ?? .local
        )
    }
}
