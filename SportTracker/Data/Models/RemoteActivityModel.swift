//
//  RemoteActivityModel.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation

struct RemoteActivityModel: Codable {
    let id: String
    let title: String
    let location: String
    let durationInMinutes: Int
    let date: Date
    let storageTypeRaw: String
}

extension RemoteActivityModel {
    
    init(from record: ActivityRecord) {
        id = record.id.uuidString
        title = record.title
        location = record.location
        durationInMinutes = record.durationInMinutes
        date = record.date
        storageTypeRaw = record.storageType.rawValue
    }
    
    var toActivityRecord: ActivityRecord? {
        guard let uuid = UUID(uuidString: id) else {
            return nil
        }
        
        return ActivityRecord(
            id: uuid,
            title: title,
            location: location,
            durationInMinutes: durationInMinutes,
            date: date,
            storageType: StorageType(rawValue: storageTypeRaw) ?? .local
        )
    }
}
