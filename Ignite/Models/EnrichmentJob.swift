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
    let validator: Validator
    
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
    case series
    case episode
}

enum Status: String, Codable {
    case inProgress = "in-progress"
    case approved = "approved"
}

struct Enrichment: Codable {
    let property: PropertyFields
    let value: StringOrArray
    let confidenceScore: Double?
    let source: String
}

struct Validator: Codable {
    let inconsistencies: [String]
    let source: String
}

enum PropertyFields: String, Codable {
    case leadActors
    case actors
    case guestStars
    case directors
    case additionalSearchTerm
    case genre
    case shortSynopsis
}

enum StringOrArray: Codable {
    case string(String)
    case array([String])
    
    var values: [String] {
        switch self {
        case .string(let str):
            return [str]
        case .array(let arr):
            return arr
        }
    }
    
    var joined: String {
        values.joined(separator: ", ")
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([String].self) {
            self = .array(array)
        } else {
            throw DecodingError.typeMismatch(
                StringOrArray.self,
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected String or [String]"
                )
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch self {
        case .string(let str):
            try container.encode(str)
        case .array(let arr):
            try container.encode(arr)
        }
    }
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
