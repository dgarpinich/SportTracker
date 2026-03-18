//
//  ActivityDataSourceProtocol.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation

protocol ActivityDataSourceProtocol {
    func save(_ record: ActivityRecord) async throws
    func fetchAll() async throws -> [ActivityRecord]
}
