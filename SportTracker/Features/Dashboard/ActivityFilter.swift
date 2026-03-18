//
//  ActivityFilter.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation

enum ActivityFilter: String, CaseIterable {
    case all
    case local
    case remote
    
    var title: String {
        switch self {
        case .all: String(localized: .dashboardFilterAll)
        case .local: String(localized: .dashboardFilterLocal)
        case .remote: String(localized: .dashboardFilterRemote)
        }
    }
}
