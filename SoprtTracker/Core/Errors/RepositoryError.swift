//
//  RepositoryError.swift
//  SportTracker
//
//  Created by Daniil Garpinich on 01.03.2026.
//

import Foundation


enum RepositoryError: LocalizedError {
    case networkError(partialData: [ActivityRecord])
    
    var errorDescription: String? {
        switch self {
        case .networkError:
            return "Network error. Will present only local data."
        }
    }
}
