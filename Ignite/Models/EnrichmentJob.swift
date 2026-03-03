//
//  EnrichmentJob.swift
//  Ignite
//
//  Created by Craig Martin on 27/2/2026.
//

import Foundation
import SwiftUI

struct EnrichmentJob: Codable, Hashable {
    let type: ContentType
    let contentName: String
    let job: String
    let status: Status
    let enrichments: [Enrichment]
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.type == rhs.type &&
        lhs.contentName == rhs.contentName &&
        lhs.job == rhs.job &&
        lhs.status == rhs.status
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(contentName)
        hasher.combine(job)
        hasher.combine(status)
    }
    
}

enum ContentType: String, Codable {
    case series = "unknown"
    case episode
}

enum Status: String, Codable {
    case inProgress = "in-progress"
    case approved = "approved"
}

struct Enrichment: Codable, Equatable {
    let leadActors: String
    let actors: String
    let guestStars: String
    let directors: String
    let additionalSearchTerm: String
    let confidenceScore: Double
    let source: String
}


extension ContentType {
    var color: Color {
        switch self {
        case .series:
            return .ignitePink
        case .episode:
            return .igniteOrange
        }
    }
}

extension ContentType {
    var text: String {
        switch self {
        case .series:
            "Series"
        case .episode:
            "Episode"
        }
    }
}

extension Status {
    var text: String {
        switch self {
        case .inProgress:
            "In Progress"
        case .approved:
            "Approved"
        }
    }
}
