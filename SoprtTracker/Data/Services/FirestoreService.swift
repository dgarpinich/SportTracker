//
//  FirestoreService.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation
import FirebaseFirestore

final class FirestoreService: ActivityDataSourceProtocol {
    private let db = Firestore.firestore()
    private let collectionName = "activities"
    
    func save(_ record: ActivityRecord) async throws {
        let model = RemoteActivityModel(from: record)
        
        try db.collection(collectionName)
            .document(model.id)
            .setData(from: model)
    }
    
    func fetchAll() async throws -> [ActivityRecord] {
        let snapshot = try await db.collection(collectionName).getDocuments()
        
        return snapshot.documents.compactMap { document in
            let model = try? document.data(as: RemoteActivityModel.self)
            return model?.toActivityRecord
        }
    }
}

